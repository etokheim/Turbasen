assert = require 'assert'
turbase = require './../coffee/turbase'

describe '#getTypes()', ->
  it 'should get all avaiable data types', (done) ->
    turbase.getTypes {},
      jsonp: (data) ->
        assert data.types instanceof Array, 'types should be an Array'
        assert.equal typeof data.count, 'number', 'count should be a number'
        assert.equal data.count, data.types.length, 'count should equal data.types.length'
        assert 'aktiviteter' in data.types, 'types should contain aktiviteter'
        assert 'bilder' in data.types, 'types should contain bilder'
        assert 'områder' in data.types, 'types should contain områder'
        assert 'steder' in data.types, 'types should contain steder'
        assert 'turer' in data.types, 'types should contain turer'
        done()

describe '#get()', ->
  before (done) ->
    this.timeout 2000
    setTimeout ->
      done()
    ,1500

  it 'should get existing document without errors', (done) ->
    req =
      eier: 'dnt'
      params:
        object: 'turer'
        id: '51c7fccf57a4f9770f528841'
      
    turbase.get req,
      jsonp: (data) ->
        throw data if data instanceof Error

        assert.equal typeof data, 'object', 'data should be an object'
        assert.equal data._id, '51c7fccf57a4f9770f528841', 'data._id should equal the request id'
        assert.equal typeof data.privat, 'object', 'private object property should show up'

        done()

  it.skip 'should get an error for nonexisting documents', (done) ->
    req =
      eier: 'dnt'
      params:
        object: 'turer'
        id: 1

    turbase.get req,
      jsonp: (data) ->
        console.log data
        done()

  it 'should hide private object properties', (done) ->
    req =
      eier: 'nrk'
      params:
        object: 'turer'
        id: '51c7fccf57a4f9770f528841'

    turbase.get req,
      jsonp: (data) ->
        throw data if data instanceof Error

        assert.equal typeof data, 'object', 'data should be an object'
        assert.equal data._id, '51c7fccf57a4f9770f528841', 'data._id should equal the request id'
        assert.equal typeof data.privat, 'undefined', 'private object property should be undefined'

        done()

describe '#list()', ->
  last = null

  before (done) ->
    this.timeout 2000
    setTimeout ->
      done()
    ,1500

  it 'should list documents in given collection', (done) ->
    req =
      eier: 'dnt'
      params:
        object: 'turer'

    turbase.list req,
      jsonp: (data) ->
        throw data if data instanceof Error

        assert.equal typeof data, 'object', 'data should be an object'
        assert data.documents instanceof Array, 'data.documents should be an array'
        assert.equal typeof data.count, 'number', 'data.count should be a number'
        assert.equal data.count, 10, 'number of documents should default to 10'
        assert.equal data.documents.length, data.count, 'data.documents.length should equal data.count'

        done()

  it 'should limit the number of items based on limit query param', (done) ->
    req =
      eier: 'dnt'
      query:
        limit: 5
      params:
        object: 'turer'

    turbase.list req,
      jsonp: (data) ->
        throw data if data instanceof Error

        last = data.documents[4]

        assert.equal data.documents.length, 5, 'number of items returned should equal 5'
        assert.equal data.count, 5, 'count should limit (5)'

        done()

  it 'should skip n items based on offset query param', (done) ->
    req =
      eier: 'dnt'
      query:
        limit: 1
        offset: 4
      params:
        object: 'turer'

    turbase.list req,
      jsonp: (data) ->
        throw data if data instanceof Error

        assert.equal typeof data.documents[0], 'object', 'First element in array should be an object'
        assert.deepEqual data.documents[0], last, 'First and last last object should be the same'

        done()

  it 'should show items editited after a certain date', (done) ->
    req =
      eier: 'dnt'
      query:
        after: '2013-01-01'
      params:
        object: 'turer'

    turbase.list req,
      jsonp: (data) ->
        throw data if data instanceof Error

        for document in data.documents
          assert document.endret > '2013-01-01', 'document should be edited after 2013-01-01'

        done()

  it 'should only list some object keys', (done) ->
    req =
      eier: 'dnt'
      params:
        object: 'turer'

    turbase.list req,
      jsonp: (data) ->
        throw data if data instanceof Error

        assert.equal Object.keys(data.documents[0]).length, 4

        done()

describe.skip '#insert()', ->
  it 'should insert all the things'

describe.skip '#update()', ->
  it 'should update all the things'

describe.skip '#updates()', ->
  it 'should updates all the things'

describe.skip '#delete()', ->
  it 'should delete all the things'
