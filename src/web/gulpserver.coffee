_ = require("lodash")
gutil = require 'gulp-util'
http = require 'http'
express = require 'express'
httpProxy = require 'http-proxy'
util = require 'util'
Socket = require('net').Socket

module.exports = (options, done) ->
  options ||= {}
  webPort = options.web?.port ? 3000
  webBase = options.web?.base ? 'generated'
  openEnabled = options.open || false
  apiProxyEnabled = gutil.env.proxy ? options.proxy? ? false
  apiProxyHost = gutil.env.proxyHost ? options.proxy?.host ? 'localhost'
  apiProxyPort = gutil.env.proxyPort ? options.proxy?.port ? 8000

  userConfig = require './config/server'
  basePath = util.format "%s/%s", process.cwd(), webBase

  app = express()
  httpServer = http.createServer(app)

  app.use require('errorhandler')()
  httpServer.on "error", handleError
  httpServer.on "clientError", handleSocketError
  app.use require('compression')()
  app.use require('serve-static')(basePath)

  if(apiProxyEnabled)
    gutil.log util.format "Proxying API requests to %s:%d", apiProxyHost, apiProxyPort
    proxyServer = new httpProxy.createProxyServer
      target:
        host: apiProxyHost
        port: apiProxyPort
    proxyServer.on "error", handleProxyError
    httpServer.on "upgrade", (req, socket, head) ->
      socket.on "error", handleSocketError
      socket.on "connect", () -> gutil.log "Socket Connected!"
      proxyServer.ws(req, socket, head)
      gutil.log "Upgrading socket request"
      return
    app.use (req, res, next) ->
      #gutil.log util.format "API Proxying to '%s'", req.url
      proxyServer.web(req, res)
  else
    bodyParser = require 'body-parser'
    app.use bodyParser.json()
    userConfig.drawRoutes?(app)

  gutil.log util.format "Starting express web server in '%s' on port %d", basePath, webPort
  httpServer.listen webPort

  if(openEnabled)
    localUrl =  _.template('http://localhost:<%- port %>', { 'port': webPort })
    require('open')(localUrl)

  done()

handleError = (err, req, res, next) ->
  gutil.log util.format "Server failed with: '%s'", err.toString() unless res
  return unless res
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


