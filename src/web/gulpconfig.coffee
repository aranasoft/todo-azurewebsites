output =
  css:      'css/app.css'
  jsApp:    'js/app.js'
  jsVendor: 'js/vendor.js'

module.exports = 
  output: output
  files:
    coffee:   'app/js/**/*.coffee'
    img:      'app/img/**/*.*'
    static:   'app/static/**/*.*'
    webfonts: [
      'vendor/webfonts/**/*.*'
      'vendor/components/font-awesome/fonts/**/*.*'
    ]
    html:
      app:    'app/pages/**/*.html'
      templates: 'app/templates/**/*.html'
      watch:  [
        'app/pages/**/*.html'
        'app/templates/**/*.html'
      ]
    js:
      app:    ['app/js/**/*.js']
      vendor: [
        'vendor/components/underscore/underscore.js'
        'vendor/components/jquery/dist/jquery.js'
	      'vendor/components/nprogress/nprogress.js'
	      'vendor/components/toastr/toastr.js'
        'vendor/components/angular/angular.js'
	      'vendor/components/angular-route/angular-route.js'
        'vendor/components/angular-animate/angular-animate.js'
	      'vendor/components/angular-resource/angular-resource.js'
        'vendor/components/signalr/jquery.signalR-2.0.2.js'
        'vendor/components/angular-signalr-hub/signalr-hub.js'
        'vendor/js/**/*.js'
      ]
    less:
      app:    'app/css/app.less'
      watch:  [
        'app/css/**'
        'vendor/components/bootstrap/less/**'
      ]
  
  htmlmin:
    removeComments: true
    removeCommentsFromCDATA: true
    collapseWhitespace: true
    collapseBooleanAttributes: false
    removeAttributeQuotes: false
    removeRedundantAttributes: true
    removeEmptyAttributes: false
    removeOptionalTags: false
    removeEmptyElements: false
  html2js:
    moduleName: 'TodoSample'
    #stripPrefix: '../Web/app/'
    prefix: "templates/"
  coffeelint:
    max_line_length:
      level: 'ignore'
  jshint:
    # enforcing options
    curly: true
    eqeqeq: true
    latedef: true
    newcap: true
    noarg: true
    # relaxing options
    boss: true
    eqnull: true
    sub: true
    # environment/globals
    browser: true
  server:
    port: 8000
    base: 'generated'
    livereload: true
    open:
      file: ''
