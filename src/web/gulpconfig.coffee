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
        'vendor/components/angular/angular.js'
	      'vendor/components/angular-route/angular-route.js'
        'vendor/components/angular-animate/angular-animate.js'
	      'vendor/components/angular-resource/angular-resource.js'
        'vendor/components/signalr/jquery.signalR.js'
        'vendor/components/angular-signalr-hub/signalr-hub.js'
        'vendor/components/nprogress/nprogress.js'
        'vendor/components/toastr/toastr.js'
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
  jsmin:
    output:
      indent_start  : 0     # start indentation on every line (only when `beautify`)
      indent_level  : 1     # indentation level (only when `beautify`)
      quote_keys    : false # quote all keys in object literals?
      space_colon   : true  # add a space after colon signs?
      ascii_only    : false # output ASCII-safe? (encodes Unicode characters as ASCII)
      inline_script : false # escape "</script"?
      width         : 200   # informative maximum line width (for beautified output)
      max_line_len  : 32000 # maximum line length (for non-beautified output)
      beautify      : false # beautify output?
      source_map    : null  # output a source map
      bracketize    : false # use brackets every time?
      comments      : false # output comments?
      semicolons    : true  # use semicolons to separate statements? (otherwise newlines)
    compress: false
      ###
      sequences     : true  # join consecutive statemets with the “comma operator”
      properties    : true  # optimize property access: a["foo"] → a.foo
      dead_code     : true  # discard unreachable code
      drop_debugger : true  # discard “debugger” statements
      unsafe        : false # some unsafe optimizations (see below)
      conditionals  : true  # optimize if-s and conditional expressions
      comparisons   : true  # optimize comparisons
      evaluate      : true  # evaluate constant expressions
      booleans      : true  # optimize boolean expressions
      loops         : true  # optimize loops
      unused        : false # drop unused variables/functions
      hoist_funs    : true  # hoist function declarations
      hoist_vars    : false # hoist variable declarations
      if_return     : true  # optimize if-s followed by return/continue
      join_vars     : true  # join var declarations
      cascade       : true  # try to cascade `right` into `left` in sequences
      side_effects  : true  # drop side-effect-free statements
      warnings      : true  # warn about potentially dangerous optimizations/code
      ###
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
    web:
      port: 8000
      base: 'generated'
    open: true
