'use strict'

# require
gulp        = require 'gulp'
$           = require('gulp-load-plugins')()
runSequence = require 'run-sequence'

# confing
config =
  SERVERPORT: '8080'
  SOURCE: './app'
  BUILD: './build'
  DATA: './data'

source =
  jade: config.SOURCE + '/**/*.jade' <% if (csspreprocessor === 'Sass') { %> 
  styles: config.SOURCE + '/styles/**/*.scss' <% } else { %>
  styles: config.SOURCE + '/styles/**/*.styl' <% } %>
  coffee: config.SOURCE + '/**/*.coffee'
  yaml: config.SOURCE + '/**/*.yml'

# task 
gulp.task 'styles', ->
  gulp.src source.styles 
    .pipe $.plumber() <% if (csspreprocessor === 'Sass') { %>
    .pipe $.filter '**/main.scss' 
    .pipe $.rubySass
      sourcemap: true
      style: 'expanded' <% } else { %>
    .pipe $.filter '**/main.styl' 
    .pipe $.stylus use: ['nib'] <% } %>
    .pipe $.autoprefixer 'last 2 version', 'ie 8', 'ie 7'
    .pipe gulp.dest config.BUILD

<% if (useTemplate) { %> gulp.task 'concat', ->
  gulp.src source.yaml
    .pipe $.concat 'all.yml'
    .pipe gulp.dest config.DATA <% } %>

gulp.task 'jade', <% if (useTemplate) {['concat']} %> -> <% if (useTemplate) { %>
  fs = require 'fs'
  yaml = require 'js-yaml'
  contents = yaml.safeLoad fs.readFileSync config.DATA + '/all.yml', 'utf-8' <% } %>

  gulp.src source.jade
    .pipe $.plumber()
    .pipe $.filter '**/index.jade'
    .pipe $.jade
      pretty: true <% if (useTemplate) { %>
      data: contents <% } %>
    .pipe gulp.dest config.BUILD

gulp.task 'coffee', ->
  gulp.src source.coffee
    .pipe $.plumber()
    .pipe $.changed config.BUILD,
      extension: '.js'
    .pipe $.coffee()
    .pipe gulp.dest config.BUILD

<% if (includeBrowserSync) { %> gulp.task 'browser-sync', ->
  browserSync = require 'browser-sync'
  browserSync.init ['./build/**/*.{html, css, js}'],
    server:
      baseDir: config.BUILD 

gulp.task 's', ['browser-sync'] <% } %>

gulp.task 'connect', ->
  connect = require 'connect'
  lr = require 'connect-livereload'
  app = connect()
    .use lr
      port: 35729
    .use connect.static config.BUILD
    # paths to bower_components should be relative to the current file
    # e.g. in app/index.html you should use ../bower_components
    .use '/bower_components', connect.static 'bower_components'

  http = require 'http'
  http.createServer app
    .listen config.SERVERPORT
    .on 'listening', ->
      console.log 'Stared connect web server on http://localhost:' + config.SERVERPORT

gulp.task 'server', ['connect', 'jade'], ->
  opn = require 'opn'
  opn 'http://localhost:' + config.SERVERPORT

gulp.task 'wiredep', ->
  wiredep = require('wiredep').stream
  gulp.src config.SOURCE + '/layout.jade'
    .pipe wiredep
      directory: 'bower_components'
    .pipe gulp.dest config.SOURCE

gulp.task 'watch', ['connect', 'server'], ->
  server = $.livereload()

  gulp.watch([
    config.BUILD + '/**/*.html'
    config.BUILD + '/**/*.css'
    config.BUILD + '/**/*.js'
  ]).on 'change', (file) ->
      server.changed file.path
    
  gulp.watch source.jade, ['jade'] <% if (useTemplate) { %>
  gulp.watch source.yaml, ['concat'] <% } %>
  gulp.watch source.styles, ['styles']
  gulp.watch source.coffee, ['coffee']
  gulp.watch 'bower.json', ['wiredep']

gulp.task 'useref', ->
  gulp.src config.BUILD + '**/*.html'
    .pipe $.useref.assets()
    .pipe $.useref.restore()
    .pipe $.useref()
    .pipe gulp.dest config.BUILD

gulp.task 'clean', ->
  gulp.src config.BUILD + '/**/*.{js,css,map}'
    .pipe $.filter ['!**/main.css', '!**/vendor.css', '!**/main.js', '!**/vendor.js']
    .pipe $.clean()

gulp.task 'build', (cb) ->
  runSequence ['jade', 'styles', 'coffee'], 'useref', 'clean', cb
