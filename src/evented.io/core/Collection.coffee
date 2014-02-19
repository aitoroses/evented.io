models = process.server.mongodb.models
redis = process.server.redis
io = process.server.io
Fiber = process.modules.Fiber

Evented = process.server

Evented.Collections = {}

class Collection

	constructor: ( collection ) ->

		# Collection basic accesibility

		@name = collection
		@model = models[collection]
		Evented.Collections[collection] = @

		# Better context

		self = @

		# # This listener its deprecated

		# io.route "#{@name}" , 

		# 	# # Default IO listeners
		# 	# - collection:find
		# 	# - collection:create
		# 	# - collection:update
		# 	# - collection:remove

		# 	find: (req) ->
		# 		req.data = req.data || {}
		# 		console.log("Find #{self.name}s: #{JSON.stringify(req.data)}")
		# 		self.model.find(req.data).exec (err, data) ->
		# 			req.io.emit("#{self.name}:found", data)
		# 			console.log("Found #{self.name}s: #{JSON.stringify(data)}")

	find: (query) ->

		# Find, returns the query instead of the result
		# The result will be evaluated on subscription

		return {
			collection: @name
			query: query
		}

		# self = @
			
		# fiber = Fiber.current
		# self.model.find(query || {}).exec (err, results) ->
		# 	fiber.run(results)

		# result = Fiber.yield();

		# return result

module.exports = Collection

