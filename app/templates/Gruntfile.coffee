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

  grunt.loadNpmTasks 'grunt-prettify'
  grunt.loadNpmTasks 'grunt-csscomb'

  grunt.registerTask 'default', ['prettify', 'csscomb']
