gulp = require 'gulp'
config = require './gulpconfig.coffee'
fs = require 'fs'
path = require 'path'

bower = require 'gulp-bower'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
concat = require 'gulp-concat'
livereload = require 'gulp-livereload'
cssmin = require 'gulp-minify-css'
html2js = require 'gulp-ng-html2js'
htmlmin = require 'gulp-htmlmin'
jslint = require 'gulp-jshint'
jslintReporter = require 'jshint-stylish'
less = require 'gulp-less'
ngmin = require 'gulp-ngmin'
uglify = require 'gulp-uglify'
_ = require 'lodash'
plumber = require 'gulp-plumber'

es = require 'event-stream'
pkg = require './package.json'
gulpserver = require './gulpserver'


gulp.task 'default', ['lint','build']

gulp.task 'run', ['lint','build','server','watch']

gulp.task 'build', [
    'install'
    'js'
    'css'
    'html'
    'copy'
  ]

gulp.task 'install', () ->
  bower()

gulp.task 'lint', ['coffeelint','jslint']

gulp.task 'coffeelint', () ->
  gulp.src(config.files.coffee)
    .pipe(plumber())
    .pipe(coffeelint(config.coffeelint))
    .pipe(coffeelint.reporter())

gulp.task 'jslint', () ->
  gulp.src(config.files.js.app)
    .pipe(plumber())
    .pipe(jslint(config.jshint))
    .pipe(jslint.reporter(jslintReporter))

gulp.task 'html', () ->
  gulp.src(config.files.html.app)
    .pipe(plumber())
    .pipe(gulp.dest('./generated'))
    #.pipe(livereload())
    .pipe(htmlmin(config.htmlmin))
    .pipe(gulp.dest('./dist'))

gulp.task 'js', ['jsApp','jsVendor']
  
gulp.task 'jsApp', () ->
  es.concat(
      gulp.src(config.files.coffee)
        .pipe(plumber())
        .pipe(coffee()),
      gulp.src(config.files.js.app),
      gulp.src(config.files.html.templates)
        .pipe(plumber())
        .pipe(gulp.dest('./generated/templates'))
        .pipe(htmlmin(config.htmlmin))
        .pipe(gulp.dest('./dist/templates'))
        .pipe(html2js(config.html2js))
    ).pipe(plumber())
    .pipe(concat(config.output.jsApp))
    .pipe(gulp.dest('./generated'))
    #.pipe(livereload())
    .pipe(ngmin())
    .pipe(uglify())
    .pipe(gulp.dest('./dist'))
  
gulp.task 'jsVendor', ['install'], () ->
  gulp.src(config.files.js.vendor)
    .pipe(plumber())
    .pipe(concat(config.output.jsVendor))
    .pipe gulp.dest('./generated')
    #.pipe(livereload())
    .pipe(gulp.dest('./dist'))
  
gulp.task 'css', ['install'], () ->
  gulp.src(config.files.less.app)
    .pipe(plumber())
    .pipe(less())
    .pipe(concat(config.output.css))
    .pipe(gulp.dest('./generated'))
    #.pipe(livereload())
    .pipe(cssmin())
    .pipe(gulp.dest('./dist'))
  
gulp.task 'clean', () ->
  gulp.src(['./dist','./generated', bowerDirectory()])
    .pipe(clean())

gulp.task 'copy', ['install'], () ->
  es.concat(
    gulp.src(config.files.img)
      .pipe(gulp.dest('./generated/img'))
      .pipe(gulp.dest('./dist/img')),
    gulp.src(config.files.static)
      .pipe(gulp.dest('./generated/'))
      .pipe(gulp.dest('./dist/')),
    gulp.src(config.files.webfonts)
      .pipe(gulp.dest('./generated/fonts'))
      .pipe(gulp.dest('./dist/fonts'))
  )

gulp.task 'watch', () ->
  gulp.watch config.files.coffee,          ['coffeelint','jsApp']
  gulp.watch config.files.js.app,          ['jslint','jsApp']
  gulp.watch config.files.js.vendor,       ['jsVendor']
  gulp.watch config.files.html.watch,      ['html']
  gulp.watch config.files.html.templates,  ['jsApp']
  gulp.watch config.files.less.watch,      ['css']
  gulp.watch [
    config.files.img
    config.files.webfonts
    config.files.static
  ],                                       ['copy']

gulp.task 'server', ['build'], (cb) ->
  gulpserver(config.server, cb)

bowerDirectory = () ->
  bowerpath = path.join(process.cwd(), ".bowerrc")
  bowerrc = fs.readFileSync(bowerpath) unless !fs.existsSync bowerpath 
  bowerConfig = JSON.parse(bowerrc) if bowerrc?
  bowerConfig?.directory || "vendor/components"
 
