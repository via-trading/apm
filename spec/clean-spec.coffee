path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'
express = require 'express'
http = require 'http'
wrench = require 'wrench'
vpm = require '../lib/vpm-cli'

describe 'vpm clean', ->
  [moduleDirectory, server] = []

  beforeEach ->
    silenceOutput()
    spyOnToken()

    app = express()
    app.get '/node/v0.10.3/node-v0.10.3.tar.gz', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node-v0.10.3.tar.gz')
    app.get '/node/v0.10.3/node.lib', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node.lib')
    app.get '/node/v0.10.3/x64/node.lib', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'node_x64.lib')
    app.get '/node/v0.10.3/SHASUMS256.txt', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'SHASUMS256.txt')
    app.get '/tarball/test-module-1.0.0.tgz', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'test-module-1.0.0.tgz')
    server =  http.createServer(app)
    server.listen(3000)

    viaHome = temp.mkdirSync('vpm-home-dir-')
    process.env.VIA_HOME = viaHome
    process.env.VIA_ELECTRON_URL = "http://localhost:3000/node"
    process.env.VIA_ELECTRON_VERSION = 'v0.10.3'

    moduleDirectory = path.join(temp.mkdirSync('vpm-test-module-'), 'test-module-with-dependencies')
    wrench.copyDirSyncRecursive(path.join(__dirname, 'fixtures', 'test-module-with-dependencies'), moduleDirectory)
    process.chdir(moduleDirectory)

  afterEach ->
    server.close()

  it 'uninstalls any packages not referenced in the package.json', ->
    removedPath = path.join(moduleDirectory, 'node_modules', 'will-be-removed')
    fs.makeTreeSync(removedPath)

    callback = jasmine.createSpy('callback')
    vpm.run(['clean'], callback)

    waitsFor 'waiting for command to complete', ->
      callback.callCount > 0

    runs ->
      expect(callback.mostRecentCall.args[0]).toBeUndefined()
      expect(fs.existsSync(removedPath)).toBeFalsy()

  it 'uninstalls a scoped package', ->
    removedPath = path.join(moduleDirectory, 'node_modules', '@types/via')
    fs.makeTreeSync(removedPath)

    callback = jasmine.createSpy('callback')
    vpm.run(['clean'], callback)

    waitsFor 'waiting for command to complete', ->
      callback.callCount > 0

    runs ->
      expect(callback.mostRecentCall.args[0]).toBeUndefined()
      expect(fs.existsSync(removedPath)).toBeFalsy()
