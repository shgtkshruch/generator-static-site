module.exports = (grunt) ->
  grunt.initConfig
    prettify:
      options:
        condense: true
        padcomments: false
        indent: 2
        indent_char: ' '
        indent_inner_html: false
        brace_style: 'expand'
        wrap_line_length: 0
        preserve_newlines: true
        unformatted: [
          'dd'
        ]
      files:
        expand: true
        cwd: 'build'
        src: ['**/*.html']
        dest: 'build'

    csscomb:
      dist:
        options:
          config: './csscomb.json'
        expand: true
        cwd: 'build'
        src: ['**/*.css']
        dest: 'build'

    'ftp-deploy':
      build: 
        auth: 
          host: 'server.com'
          port: 21
          authKey: 'key1'
        src: 'build'
        dest: '/'
        exclusions: ['**/.DS_Store']

  grunt.loadNpmTasks 'grunt-prettify'
  grunt.loadNpmTasks 'grunt-csscomb'
  grunt.loadNpmTasks 'grunt-ftp-deploy'
