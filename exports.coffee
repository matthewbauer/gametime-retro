os = require 'os'
fs = require 'fs'
url = require 'url'
path = require 'path'

request = require 'request'
JSZip = require 'jszip'

getCoreFile = (core, platform) ->
  platform ?= process.platform
  if platform is 'win32'
    "#{core}.dll"
  else if platform is 'darwin'
    "#{core}.dylib"
  else
    "#{core}.so"

getCorePath = (corefile, platform) ->
  platform ?= process.platform
  corepath = path.join os.tmpdir(), corefile

getCoreURL = (corefile, platform, arch) ->
  platform ?= process.platform
  arch ?= process.arch
  target = switch platform
    when 'win32'
      if arch is 'ia32'
        'win-x86'
      else
        'win-x86_64_w32'
    when 'darwin'
      if arch is 'ia32'
        'osx-x86'
      else
        'osx-x86_64'
    else 'linux/x86_64'
  url.format
    protocol: 'http'
    hostname: 'buildbot.libretro.com'
    pathname: path.join 'nightly', target, 'latest', "#{corefile}.zip"

fetchCore = (corefile, platform) ->
  platform ?= process.platform
  new Promise (resolve, reject) ->
    request
      url: getCoreURL(corefile, platform)
      encoding: null
    , (err, resp, body) ->
      if err or resp.statusCode != 200
        reject()
        return
      zip = new JSZip body
      file = zip.file corefile
      if file is null
        reject()
        return
      corepath = getCorePath corefile, platform
      fs.writeFile corepath, file.asArrayBuffer(), (err) ->
        if err
          reject()
          return
        resolve corepath

getCore = (core) ->
  new Promise (resolve, reject) ->
    corefile = getCoreFile core
    corepath = getCorePath corefile
    fs.exists corepath, (exists) -> # DEPRECATED!!!
      if exists
        resolve corepath
        return
      fetchCore(corefile).then resolve, reject

module.exports = {getCore, fetchCore, getCoreURL, getCorePath, getCoreFile}
