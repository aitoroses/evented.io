redis = process.server.redis
Fiber = process.modules.Fiber
Evented = process.server
log = process.server.logger

module.exports = Pubsub = ->

  self = @

  @channels = {}

  @publish = (collection, callback) ->

    name = collection.name

    # Clean cached keys on redis
    redis.multi().keys('User:*', (err, keys) ->
      for key in keys
        redis.del key, null, (err) -> 
          if err? then throw err
    ).exec()
    
    self.channels[name] = callback


    #********************
    # INSERT LISTENER   #
    #********************

    # Register insert event for this publishing

    log.info("Registering Event: 'insert:#{name}'")
    Evented.io.route "insert:#{name}", (req) ->
      log.info("<---- insert:#{name}")
      # When we have an insertion
      # we broadcast "inserted:publishing_name" to all users with the new data
      
      Fiber(->
      
        fiber = Fiber.current
        redis = process.server.redis
        
        redis.get "sess:#{req.sessionID}", (err, session) -> 
          fiber.run(session)          
        
        session = Fiber.yield()
        
        userId = null
        if session?
          session = JSON.parse(session)
          if session.passport? && session.passport.user?
            userId = session.passport.user
        
        # Get the collection from redis
        collection.model.create req.data, (err, user) ->
          if err?
            Evented.io.broadcast "inserted:#{name}", err
            log.info("inserted:#{Error} ---->")
            return
          # Consider executing sincronization via chanels
          Evented.io.broadcast "inserted:#{name}", user
          log.info("inserted:#{name} ---->")

      ).run()

    #********************
    # UPDATE LISTENER   #
    #********************
    
    # Register insert event for this publishing

    log.info("Registering Event: 'update:#{name}'")
    Evented.io.route "update:#{name}", (req) ->
      log.info("<---- update:#{name}")
      # When we have an insertion
      # we broadcast "inserted:publishing_name" to all users with the new data
      
      Fiber(->
      
        fiber = Fiber.current
        redis = process.server.redis
        
        redis.get "sess:#{req.sessionID}", (err, session) -> 
          fiber.run(session)          
        
        session = Fiber.yield()
        
        userId = null
        if session?
          session = JSON.parse(session)
          if session.passport? && session.passport.user?
            userId = session.passport.user
        
        query = req.data.query
        collection.model.findByIdAndUpdate query._id, {$set: req.data.data}, (err, model) ->
          if err?
            Evented.io.broadcast "update:#{name}", err
            log.info("updated:#{err.message} ---->")
            return
          Evented.io.broadcast "updated:#{name}", model
          log.info("updated:#{name} ---->")
          # Consider executing sincronization via chanels in future


      ).run() 

    #********************
    # REMOVE LISTENER   #
    #********************
    
    # Register insert event for this publishing

    log.info("Registering Event: 'remove:#{name}'")
    Evented.io.route "remove:#{name}", (req) ->
      log.info("<---- remove:#{name}")
      # When we have an insertion
      # we broadcast "inserted:publishing_name" to all users with the new data
      
      Fiber(->
      
        fiber = Fiber.current
        redis = process.server.redis
        
        redis.get "sess:#{req.sessionID}", (err, session) -> 
          fiber.run(session)          
        
        session = Fiber.yield()
        
        userId = null
        if session?
          session = JSON.parse(session)
          if session.passport? && session.passport.user?
            userId = session.passport.user
        
        query = req.data.query
        collection.model.findByIdAndRemove query._id, (err, model) ->
          if err?
            Evented.io.broadcast "removed:#{name}", err
            log.info("removed:#{err.message} ---->")
            return
          Evented.io.broadcast "removed:#{name}", model
          log.info("removed:#{name} ---->")
          # Consider executing sincronization via chanels in future


      ).run() 

  

  # Susbscribe listeners
  # ====================

  process.server.io.route 'subscribe', (req) ->

    subscription = (-> if req.data? then if req.data.subscribe? then return req.data.subscribe)()
    log.info("Subscription to: #{subscription}")

    # Get the user id if exists first

    redis.get "sess:#{req.sessionID}", (err, session) ->

      # get the Mongo User Id first
      
      userMongoId = null
      if session?
        parsed = JSON.parse(session)
        userMongoId = parsed.passport.user

      # When a user sends a subscription event, data has to be sended to the user

      Fiber(->

        id = req.sessionID
        sub = subscription

        fiber = Fiber.current

        fiber.userId = -> process.modules.mongoose.Types.ObjectId(userMongoId)

        if @channels[sub]?

          # Register this key in redis
          query = self.channels[sub].call(fiber) || {}
          redis.set "#{query.collection}:#{id}", JSON.stringify(query), (err, key) -> 
            if err? then throw err

            # Prepare data to send
            Evented.Collections[query.collection].model.find query.query, (err, results) ->
              log.info("Emiting data: #{sub}")
              req.socket.emit "subscribe:#{sub}" , {data: results, collection: query.collection}

      ).run()
    
  process.server.io.route 'user', (req) ->

    log.info "user <-----"

    Fiber(->
      
      fiber = Fiber.current
      redis = process.server.redis
      
      redis.get "sess:#{req.sessionID}", (err, session) -> 
        fiber.run(session)          
      
      session = Fiber.yield()
      
      userId = null
      if session?
        session = JSON.parse(session)
        if session.passport? && session.passport.user?
          userId = session.passport.user

      process.server.mongodb.models.User.findOne {_id: userId} , (err, user) ->
        log.info "-----> user"
        req.io.emit('user', user)

    ).run()

  # Return Pubsub 
  return self
