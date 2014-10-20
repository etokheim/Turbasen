    os = require 'os'
    redis = require './db/redis'
    mongo = require './db/mongo'

## check()

This is the system check function. It retrives the current status from Redis
and MongoDB and perfoms a simple error checking on the returned data before
returning it to the user.

If a service is unresponsive this function will time out after 2 seconds with
a `500` status code.

    exports.check = (req, res, next) ->
      return res.status(403).end() if req.usr not in ['DNT', 'Pingdom']

      status = 200
      service = {}
      serviceCount = 2
      callbackCount = 0

      ret = ->
        return if ++callbackCount > 1
        status = 500 if Object.keys(service).length isnt serviceCount
        res.json status, service

      redis.info (err, info) ->
        service.Redis = {}

        if err
          status = 500
          service.Redis.status = 0
          service.Redis.message = err.toString()
        else
          service.Redis.status = 1
          service.Redis.message = info.toString().split("\r\n").sort()

          ret() if Object.keys(service).length is serviceCount

      mongo.db.command {dbStats:true}, (err, info) ->
        service.Mongo = {}

        if err
          status = 500
          service.Mongo.status = 0
          service.Mongo.message = err.toString()
        else
          service.Mongo.status = 1
          service.Mongo.message = info

        ret() if Object.keys(service).length is serviceCount

        setTimeout ret, 2000

