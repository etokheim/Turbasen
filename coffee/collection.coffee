"use strict"

collections = {}

exports.param = (req, res, next, collection) ->
  if collections[collection]
    req.col = collections[collection]
    return next()

  req.db.collection collection, (err, col) ->
    return next err if err
    collections[collection] = req.col = col
    return next()

exports.options = (req, res, next) ->
  res.setHeader 'Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT'
  res.send()

exports.get = (req, res, next) ->
  query = {}
  query.endret = {$gte:req.query.after} if req.query.after

  fields = {navn: true}

  options =
    limit: Math.min((parseInt(req.query.limit) or 20), 100)
    skip: parseInt(req.query.skip) or 0
    sort: 'endret'

  req.col.find(query, fields, options).toArray (err, docs) ->
    return next err if err
    res.json documents: docs, count: docs.length

exports.post = (req, res, next) ->
  return res.send 400, 'Payload Missing' if Object.keys(req.body).length is 0
  req.body = [req.body] if (req.body instanceof Array) is false

  ret = []
  for item, i in req.body
    item._id = ObjectID(item._id) if item._id # @TODO restrict this
    # @TODO item.opprettet
    # @TODO item.endret
    # @TODO item.tilbyder
    do (item, i) ->
      req.col.save item, safe: true, (err, doc) ->
        return next(err) if err
        ret[i] = doc._id
        return res.json 201, documents: ret, count: ret.length if ret.length is req.body.length

exports.patch = (req, res, next) ->
  res.send 501, 'Not Implmented'

exports.put = (req, res, next) ->
  res.send 501, 'Not Implmented'

