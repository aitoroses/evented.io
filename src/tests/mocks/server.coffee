ioRoutes = {}

# Mock up the process.server
server =
  mongodb: 
    models: 
      User: 
        find: (query, callback) ->
            callback(null, {})

        findOne: (query, callback) ->
          callback(null, {name: "Aitor"})

        create: (data, callback) ->
          data._id = "randomId"
          callback(null, data)

        update: (query, data, callback) ->
          callback(null, {
            _id: "randomId"
            user: "Robert"
            lastname: 'Lopez'
          })

        findByIdAndUpdate: (query, data, callback) ->
          callback(null, {
            _id: "randomId"
            user: "Robert"
            lastname: "Lopez"
          })
  io: 
    route: (name, callback) ->
      exports.ioRoutes[name] = callback

    broadcast: (event, data)->
      calls.add(event, data)

  redis:
    multi: -> 
      calls.add('multi')
      return {
        keys: (key, callback) ->
          calls.add('multi.keys')
          return {
            exec: ->
              calls.add('multi.keys.exec')
          }
      }
    get: (name, callback) ->
      session = JSON.stringify {
        passport: {
          user: 'ThisIsTheMongoId'
        }
      }

      callback(null, session)
    set: (key, data, callback) ->
      callback(null, {})

  logger: 
    info: ->

modules = {
  Fiber : (callback) ->
    self = @
    return {
      run: -> callback()
    }
}
modules.Fiber.yield =  -> @current.result
modules.Fiber.current = {
  run: (result) -> @result = result
}

calls = {}
calls.data = {}
calls.add = (name, metadata) ->
  count = this[name] || 1
  this[name] =  count
  this.data[name] = metadata

exports.calls = calls
exports.server = server
exports.modules = modules
exports.ioRoutes = ioRoutes