'use strict'

# require
gulp        = require 'gulp'
$           = require('gulp-load-plugins')()

# confing
config =
  SERVERPORT: '8080'
  SOURCE: './app'
  BUILD: './build'
  DATA: './data'

source =
  jade: config.SOURCE + '/**/*.jade'
  styles: config.SOURCE + '/styles/main.*'
  coffee: config.SOURCE + '/**/*.coffee'
  yaml: config.SOURCE + '/**/*.yml'
  images: config.SOURCE + '/**/*.{png, jpg, gif}'

# task 
gulp.task 'styles', ->
  gulp.src source.styles <% if (csspreprocessor === 'Sass') { %>
    .pipe $.rubySass
      sourcemap: true
      style: 'expanded' <% } if (csspreprocessor === "Stylus") { %>
    .pipe $.stylus use: ['nib'] <% } %>
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
    .pipe $.jade
      pretty: true <% if (useTemplate) { %>
      data: contents <% } %>
    .pipe gulp.dest config.BUILD

gulp.task 'coffee', ->
  gulp.src source.coffee
    .pipe $.coffee()
    .pipe gulp.dest config.BUILD

gulp.task 'images', ->
  gulp.src source.images
    .pipe $.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
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

gulp.task 'watch', ['connect', 'server'], ->
  server = $.livereload()

  gulp.watch([
    config.BUILD + '/**/*.html'
    config.BUILD + '/**/*.css'
    config.BUILD + '/**/*.js'
    config.BUILD + '/**/*.{png, jpg, gif}'
  ]).on 'change', (file) ->
      server.changed file.path
    
  gulp.watch source.jade, ['jade'] <% if (useTemplate) { %>
  gulp.watch source.yaml, ['concat'] <% } %>
  gulp.watch source.styles, ['styles']
  gulp.watch source.coffee, ['coffee']
  gulp.watch source.images, ['images']
