"use strict"

request = require 'supertest'
assert = require 'assert'

app = req = null

before ->
  app = module.parent.exports
  req = request(app)

describe 'OPTIONS', ->
  it 'should return allowed http methods', (done) ->
    req.options('/turer?api_key=dnt')
      .expect(200)
      .expect('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT', done)

describe 'POST', ->
  it 'should insert single object in collection and return ObjectID', (done) ->
    doc = name: 'tobi'
    req.post('/turer?api_key=dnt').send(doc)
      .expect(201)
      .end (err, res) ->
        throw err if err
        assert.equal res.body.documents.length, 1
        assert.equal res.body.count, 1
        assert.equal typeof res.body.documents[0], 'string'
        done()

  it 'should insert multiple objects in collection and return ObjectIDs', (done) ->
    docs = [
      {name: 'foo'}
      {name: 'bar'}
    ]
    req.post('/turer?api_key=dnt').send(docs)
      .expect(201)
      .end (err, res) ->
        throw err if err
        assert.equal res.body.documents.length, 2
        assert.equal res.body.count, 2
        assert.equal typeof res.body.documents[0], 'string'
        assert.equal typeof res.body.documents[1], 'string'
        done()

  it 'should handle rapid requests to collection', (done) ->
    count = 0
    target = 200
    for i in [1..target]
      req.post('/turer?api_key=dnt').send({num:i}).expect(201).end (err, res) ->
        throw err if err
        assert.equal res.body.documents.length, 1
        assert.equal res.body.count, 1
        assert.equal typeof res.body.documents[0], 'string'
        done() if ++count is target

  it 'should return error for missing request body', (done) ->
    req.post('/turer?api_key=dnt')
      .expect(400, done)

describe 'GET', ->
  it 'should get the collection', (done) ->
    req.get('/turer?api_key=dnt')
      .expect(200)
      .end (err, res) ->
        assert res.body.documents.length > 0
        done()

describe 'PUT', ->
  it 'should not be implemeted', (done) ->
    req.put('/turer?api_key=dnt')
      .expect(501, done)

describe 'PATCH', ->
  it 'should not be implemented', (done) ->
    req.patch('/turer?api_key=dnt')
      .expect(501, done)

describe 'DELETE', ->
  it 'should not be able to DELETE', (done) ->
    req.del('/turer?api_key=dnt')
      .expect(405, done)
