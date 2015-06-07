module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files: [
          expand: true
          src: ['exports.coffee']
          ext: '.js'
        ]
    mochaTest:
      test:
        options:
          reporter: 'spec',
          require: [
            'coffee-script/register'
            'coffee-coverage/register-istanbul'
          ]
        src: 'spec/*'
  grunt.registerTask 'test', ['mochaTest']
  grunt.registerTask 'build', ['coffee:compile']
  grunt.registerTask 'default', ['build', 'test']
