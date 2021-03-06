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
  jade: config.SOURCE + '/**/*.jade' <% if (csspreprocessor === 'Sass') { %> 
  styles: config.SOURCE + '/styles/**/*.scss' <% } else { %>
  styles: config.SOURCE + '/styles/**/*.styl' <% } %>
  sprite: config.SOURCE + '/images/**/*.{jpg,png,gif}'
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

gulp.task 'sprite', ->
  spritesmith = require 'gulp.spritesmith'
  spriteData = gulp.src source.sprite
    .pipe spritesmith
      imgName: 'sprite.png'
      cssName: '_sprite.scss'
      imgPath: '../images/sprite.png'
      cssFormat: 'scss'

  spriteData.img.pipe gulp.dest config.BUILD + '/images'
  spriteData.css.pipe gulp.dest config.SOURCE + '/styles'

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
  serveStatic = require 'serve-static'
  lr = require 'connect-livereload'
  app = connect()
    .use lr
      port: 35729
    .use searveStatic config.BUILD
    # paths to bower_components should be relative to the current file
    # e.g. in app/index.html you should use ../bower_components
    .use '/bower_components', searveStatic 'bower_components'

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
  gulp.src config.BUILD + '/**/*.{js,css,map}', {read: false}
    .pipe $.filter ['!**/{main,vendor,ie}.{js,css}']
    .pipe $.rimraf()

gulp.task 'min', ->
  saveLisense = require 'uglify-save-license'

  htmlFilter = $.filter '**/*.html'
  cssFilter = $.filter '**/*.css'
  jsFilter = $.filter '**/*.js'

  gulp.src config.BUILD + '/**/*.{html,css,js}'
    .pipe htmlFilter
    .pipe $.minifyHtml()
    .pipe htmlFilter.restore()
    .pipe cssFilter
    .pipe $.minifyCss()
    .pipe cssFilter.restore()
    .pipe jsFilter
    .pipe $.uglify preserveComments: saveLisense
    .pipe jsFilter.restore()
    .pipe gulp.dest config.BUILD

runSequence = require 'run-sequence'
gulp.task 'prebuild', (cb) ->
  runSequence 'sprite', ['jade', 'styles', 'coffee'], 'useref', 'clean', cb

<% if (includeGrunt) { %>
require('gulp-grunt')(gulp)
gulp.task 'grunt-build', ->
  gulp.run 'grunt-prettify'
  gulp.run 'grunt-csscomb'

gulp.task 'grunt-deploy', ->
  gulp.run 'grunt-ftp-deploy'

gulp.task 'build', (cb) ->
  runSequence 'prebuild', 'grunt-build', cb

gulp.task 'deploy', (cb) ->
  runSequence 'prebuild', 'min', 'grunt-deploy', cb
<% } %>

gulp.task 'production', (cb) ->
  runSequence 'prebuild', 'min', cb
