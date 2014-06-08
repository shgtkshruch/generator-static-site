'use strict';

var fs = require('fs');
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');
var wiredep = require('wiredep');

var BlogGenerator = yeoman.generators.Base.extend({
  init: function () {
    // this.pkg = require('../package.json');
    // this.options['skip-install'] = true;

    // this.on('end', function () {
    //   if (!this.options['skip-install']) {
    //   }
    // });
  },

  askFor: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay('Welcome to the marvelous Blog generator!'));

    var prompts = [{
      type: 'confirm',
      name: 'useTemplate',
      message: 'Do you use Jade template?',
      default: true
    }, {
      type: 'list',
      name: 'csspreprocessor',
      message: 'Which do you use CSS preprosesser?',
      choices: [
        'Sass',
        'Stylus'
        ],
      default: 'Sass'
    }, {
      type: 'checkbox',
      name: 'jslib',
      message: 'What do you use JavaSript library?',
      choices: [{
        name: 'Modernizr',
        value: 'includeModernizr'
      }, {
        name: 'HTML5shiv',
        value: 'includeHTML5shiv'
      }]
    }, {
      type: 'checkbox',
      name: 'csslib',
      message: 'What do you use CSS library?',
      choices: [{
        name: 'Normalize CSS',
        value: 'includeNormalize'
      }, {
        name: 'HTML5 Reset CSS',
        value: 'includeReset'
      }]
    }, {
      type: 'confirm',
      name: 'includeBrowserSync',
      message: 'Do you use browser-sync?',
      default: false
    }];

    this.prompt(prompts, function (answers) {
      var jslib = answers.jslib;
      var csslib = answers.csslib;

      var hasjs = function (feat) {
        return jslib.indexOf(feat) !== -1;
      }

      var hascss = function (feat) {
        return csslib.indexOf(feat) !== -1;
      }

      this.useTemplate = answers.useTemplate;
      this.csspreprocessor = answers.csspreprocessor;
      this.includeBrowserSync = answers.includeBrowserSync;
      this.includeModernizr = hasjs('includeModernizr');
      this.includeHTML5shiv = hasjs('includeHTML5shiv');
      this.includeNormalize = hascss('includeNormalize');
      this.includeReset = hascss('includeReset');

      done();
    }.bind(this));
  },

  app: function () {
    this.mkdir('app');
    this.mkdir('app/styles');
    this.mkdir('app/scripts');
    this.mkdir('app/images');

    this.copy('_package.json', 'package.json');
    this.copy('_bower.json', 'bower.json');
  },

  jade: function () {
    this.copy('index.jade', 'app/index.jade');

    // layout
    this.copy('layout.jade', 'app/layout.jade');
    this.copy('layout/html-head.jade', 'app/layout/html-head.jade');
    this.copy('layout/ie-script.jade', 'app/layout/ie-script.jade');
    this.copy('layout/ogp.jade', 'app/layout/ogp.jade');

    // data
    if (this.useTemplate) {
      this.mkdir('app/data');
      this.copy('index.yml', 'app/data/index.yml');
    }
  },

  gulp: function () {
    this.copy('gulpfile.coffee', 'gulpfile.coffee');
  },

  projectfiles: function () {
    this.copy('editorconfig', '.editorconfig');
    this.copy('jshintrc', '.jshintrc');
  },

  install: function () {
    var done = this.async();
    this.installDependencies({
      callback: function () {
        var bowerJson = JSON.parse(fs.readFileSync('./bower.json'));

        wiredep({
          bowerJson: bowerJson,
          directory: 'bower_components',
          exclude: ['modernizr.js', 'html5shiv.js'],
          src: 'app/layout.jade'
        });
        done();
      }.bind(this),
      skipInstall: this.options['skip-install']
    });
  }

});

module.exports = BlogGenerator;
