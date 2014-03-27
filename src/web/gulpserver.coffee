_ = require("lodash")
gutil = require 'gulp-util'
http = require 'http'
express = require 'express'
httpProxy = require 'http-proxy'
util = require 'util'
Socket = require('net').Socket
bodyParser = require 'body-parser'

module.exports = (options, done) ->
  options ||= {}
  webPort = options.web?.port ? 3000
  webBase = options.web?.base ? 'generated'
  liveReloadEnabled = options.livereload || false
  openEnabled = options.open || false
  apiProxyEnabled = gutil.env.proxy ? options.proxy? ? false
  apiProxyHost = gutil.env.proxyHost ? options.proxy?.host ? 'localhost'
  apiProxyPort = gutil.env.proxyPort ? options.proxy?.port ? 8000

  userConfig = require './config/server'
  basePath = util.format "%s/%s", process.cwd(), webBase

  app = express()
  httpServer = http.createServer(app)

  app.configure ->
    app.use(express.errorHandler())
    httpServer.on "error", handleError
    httpServer.on "clientError", handleSocketError
    app.use(express.compress())
    app.use(require('connect-livereload')()) if liveReloadEnabled == true
    app.use(express.static(basePath))
    #addBodyParserCallbackToRoutes(app)

    if(apiProxyEnabled)
      gutil.log util.format "Proxying API requests to %s:%d", apiProxyHost, apiProxyPort
      proxyServer = new httpProxy.createProxyServer
        target:
          host: apiProxyHost
          port: apiProxyPort
      proxyServer.on "error", handleProxyError
      httpServer.on "upgrade", (req, socket, head) ->
        socket.on "connect", () -> gutil.log "Socket Connected!"
        gutil.log "Upgrading socket request"
        proxyServer.ws(req, socket, head)
        return
      app.use (req, res, next) ->
        proxyServer.web(req, res)
    else
      app.use(bodyParser())
      userConfig.drawRoutes?(app)

    #app.use(express.bodyParser())

  gutil.log util.format "Starting express web server in '%s' on port %d", basePath, webPort
  httpServer.listen webPort

  if(openEnabled)
    localUrl =  _.template('http://localhost:<%- port %>', { 'port': webPort })
    require('open')(localUrl)

  done()

handleError = (err, req, res, next) ->
  return next() if err?
  res.writeHead?(500,
    'Content-Type': 'text/plain'
  )
  gutil.log util.format "Request to '%s' failed with: '%s'", req.url, err.toString()
  res.end util.format "Request to '%s' failed with: '%s'", req.url, err.toString()

handleSocketError = (err, socket) ->
  gutil.log util.format "Socket failed with: '%s'", err.toString()

handleProxyError = (err, req, res) ->
  if res instanceof Socket
    gutil.log util.format "Socket Proxying to '%s' failed with: '%s'", req.url, err.toString()
    res.destroy()
    return
  gutil.log util.format "API Proxying to '%s' failed with: '%s'", req.url, err.toString()
  res.writeHead 500,
    'Content-Type': 'text/plain'
  res.end util.format "API Proxying to '%s' failed with: '%s'", req.url, err.toString() unless res instanceof Socket

###
addBodyParserCallbackToRoutes = (app) ->
  bodyParser = express.bodyParser()
  _(["get", "post", "patch", "put", "delete", "options", "head"]).each (verb) ->
    _(app.routes[verb]).each (route) ->
      route.callbacks.unshift(bodyParser)
###

