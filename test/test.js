/*global describe, beforeEach, it */
'use strict';

var path = require('path');
var helpers = require('yeoman-generator').test;

describe('static-site generator', function () {
  beforeEach(function (done) {
    helpers.testDirectory(path.join(__dirname, 'temp'), function (err) {
      if (err) {
        return done(err);
      }

      this.app = helpers.createGenerator('static-site:app', [
        '../../app', [
          helpers.createDummyGenerator(),
          'mocha:app'
        ]
      ]);
      this.app.options['skip-install'] = true;

      done();
    }.bind(this));
  });

  it('the generator can be required without throwing', function () {
    // not testing the actual run of generators yet
    this.app = require('../app');
  });

  it('creates expected files', function (done) {

    var expected = [
      // add files you expect to exist here.
      '.editorconfig',
      'bower.json',
      'gulpfile.coffee',
      'package.json'
    ];

    helpers.mockPrompt(this.app, {
      useTemplate: false,
      csspreprocessor: 'Sass',
      jslib: ['includeHTML5shiv'],
      csslib: ['includeNormalize'],
      includeBrowserSync: false,
      includeGrunt: true
    });

    this.app.run({}, function () {
      helpers.assertFile(expected);
      done();
    });
  });

});
