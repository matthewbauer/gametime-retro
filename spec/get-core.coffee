should = require 'should'
core = require '../exports'
request = require 'request'
fs = require 'fs'

cores = [
  'snes9x_libretro'
  '2048_libretro'
]

platforms = [
  'darwin'
  'win32'
  'linux'
]

for corename in cores
  do (corename) ->
    describe "Working with #{corename} library.", ->
      for platform in platforms
        do (platform) ->
          corefile = core.getCoreFile(corename, platform)
          it "url should resolve to 200 for #{platform}", (done) ->
            @timeout 3000
            url = core.getCoreURL corefile, platform
            request url, (err, resp, body) ->
              should.not.exist err
              resp.statusCode.should.equal 200
              body.should.exist
              done()
          it "should be able to fetch core", (done) ->
            @timeout 3000
            core.fetchCore(corefile, platform).then (path) ->
              should.exist path
              fs.readFile path, (err, data) ->
                should.not.exist err
                should.exist data
                done()
            , done
          it "caching should work", (done) ->
            @timeout 1000
            core.getCore(corename).then (path) ->
              fs.readFile path, (err, data) ->
                should.not.exist err
                should.exist data
                done()
            , done
