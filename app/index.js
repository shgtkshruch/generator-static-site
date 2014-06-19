'use strict';

var fs = require('fs');
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');
var wiredep = require('wiredep');

var StaticSiteGenerator = module.exports = function StaticSiteGenerator(args, options, config) {
  yeoman.generators.Base.apply(this, arguments);

  this.testFramework = options['test-framework'] || 'mocha';

  options['test-framework'] = this.testFramework;

  this.hookFor('test-framework', {
    as: 'app',
    options: {
      options: {
        'skip-install': options['skip-install']
      }
    }
  });

  this.options = options;
};

util.inherits(StaticSiteGenerator, yeoman.generators.Base);

StaticSiteGenerator.prototype.askFor = function askFor() {
  var done = this.async();

  // Have Yeoman greet the user.
  this.log(yosay('Welcome to the marvelous Blog generator!'));

  var prompts = [{
    // Jade template
    type: 'confirm',
    name: 'useTemplate',
    message: 'Do you use Jade template?',
    default: true
  }, {
    // CSS preprosesser
    type: 'list',
    name: 'csspreprocessor',
    message: 'Which do you use CSS preprosesser?',
    choices: [
      'Sass',
      'Stylus'
      ],
    default: 'Sass'
  }, {
    // JavaSript library
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
    // CSS library
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
    // Cross browser test
    type: 'confirm',
    name: 'includeBrowserSync',
    message: 'Do you use browser-sync?',
    default: false
  }, {
    // post css processor with Grunt
    type: 'confirm',
    name: 'includeGrunt',
    message: 'Do you use post css pocessor?',
    default: 'false'
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
    this.includeGrunt = answers.includeGrunt;

    this.includeModernizr = hasjs('includeModernizr');
    this.includeHTML5shiv = hasjs('includeHTML5shiv');
    this.includeNormalize = hascss('includeNormalize');
    this.includeReset = hascss('includeReset');

    done();
  }.bind(this));
};

StaticSiteGenerator.prototype.app = function app() {
  this.mkdir('app');
  this.mkdir('app/styles');
  this.mkdir('app/scripts');
  this.mkdir('app/images');

  this.copy('_package.json', 'package.json');
  this.copy('_bower.json', 'bower.json');
};

StaticSiteGenerator.prototype.jade = function jade() {
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
};

StaticSiteGenerator.prototype.sass = function sass() {
  if (this.csspreprocessor === 'Sass') {
    this.copy('main.scss', 'app/styles/main.scss');
  }
};

StaticSiteGenerator.prototype.stylus = function stylus() {
  if (this.csspreprocessor === 'Stylus') {
    this.copy('main.styl', 'app/styles/main.styl');
  }
};

StaticSiteGenerator.prototype.coffee = function coffee() {
  this.copy('script.coffee', 'app/scripts/script.coffee');
};

StaticSiteGenerator.prototype.gulp = function gulp() {
  this.template('gulpfile.coffee', 'gulpfile.coffee');
};

StaticSiteGenerator.prototype.grunt = function grunt() {
  if (this.includeGrunt) {
    this.copy('gruntfile.coffee', 'gruntfile.coffee');
    this.copy('csscomb.json', 'csscomb.json');
  }
};

StaticSiteGenerator.prototype.git = function git() {
  this.copy('gitignore', '.gitignore');
}

StaticSiteGenerator.prototype.projectfiles = function projectfiles() {
  this.copy('editorconfig', '.editorconfig');
  this.copy('jshintrc', '.jshintrc');
};

StaticSiteGenerator.prototype.install = function install() {
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
};
