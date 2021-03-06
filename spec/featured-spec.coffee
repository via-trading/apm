path = require 'path'
express = require 'express'
http = require 'http'
vpm = require '../lib/vpm-cli'

describe 'vpm featured', ->
  server = null

  beforeEach ->
    silenceOutput()
    spyOnToken()

    app = express()
    app.get '/packages/featured', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'packages.json')
    app.get '/themes/featured', (request, response) ->
      response.sendfile path.join(__dirname, 'fixtures', 'themes.json')

    server =  http.createServer(app)
    server.listen(3000)

    process.env.VIA_API_URL = "http://localhost:3000"

  afterEach ->
    server.close()

  it 'lists the featured packages and themes', ->
    callback = jasmine.createSpy('callback')
    vpm.run(['featured'], callback)

    waitsFor 'waiting for command to complete', ->
      callback.callCount > 0

    runs ->
      expect(console.log).toHaveBeenCalled()
      expect(console.log.argsForCall[1][0]).toContain 'beverly-hills'
      expect(console.log.argsForCall[2][0]).toContain 'multi-version'
      expect(console.log.argsForCall[3][0]).toContain 'duckblur'

  describe 'when the theme flag is specified', ->
    it "lists the featured themes", ->
      callback = jasmine.createSpy('callback')
      vpm.run(['featured', '--themes'], callback)

      waitsFor 'waiting for command to complete', ->
        callback.callCount > 0

      runs ->
        expect(console.log).toHaveBeenCalled()
        expect(console.log.argsForCall[1][0]).toContain 'duckblur'
        expect(console.log.argsForCall[2][0]).toBeUndefined()
