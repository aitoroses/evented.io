
restifier = (id_field, name, version, model) ->

	get = 
		method: 'get'
		path: "/#{name}/:id"
		version: version
		description: "Get a #{name}"
		docURL: "/#{name}Controller#GET_" + name.toUpperCase() + '_ACTION'
		params:
			required: []
			optional: []
		allowedUserKinds: []
		roles: []
		callback: (req, res, completeCall) ->

			result = {}

			query = {}
			query[id_field] = req.params.id

			model.findOne(query).exec (err, retrieved)->

				if err
					return completeCall
						httpStatus: 500
						metadata:	
							error: err
				if not retrieved?
					return completeCall
						httpStatus: 500
						metadata:	
							message: "#{name} not found."

				result[name] = retrieved

				completeCall result


	#//============================================================================

	getAll = 
		method: 'get'
		path: "/#{name}"
		version: version
		description: "Get all the #{name}s"
		docURL: '/#{name}Controller#GET_ALL_' + name.toUpperCase() + '_ACTION'
		params:
			required: []
			optional: []
		allowedUserKinds: []
		roles: []
		callback: (req, res, completeCall) ->
			
			result = {}

			model.find().exec (err, retrieved)->

				if err
					return completeCall
						httpStatus: 500
						metadata:
							error: err
				if not retrieved?
					return completeCall
						httpStatus: 500
						metadata:
							message: "#{name}s not found."

				# ------------------------------------
				# ## Image data replacement
				for obj in retrieved
					if obj.image?
						if obj.image.name?
							obj.image = obj.image.name
				# ------------------------------------

				result[name+'s'] = retrieved

				completeCall result

	#//============================================================================

	create = 
		method: 'post'
		path: "/#{name}"
		version: version
		description: "Create a #{name}"
		docURL: '/#{name}Controller#POST_' + name.toUpperCase() + '_ACTION'
		params:
			required: []
			optional: []
		allowedUserKinds: []
		roles: []
		callback: (req, res, completeCall) ->

			result = {}
			
			if req.args[name]?
				recieved = req.args[name]
			else return completeCall
				httpStatus: 500
				metadata:
					message: "You haven't send a #{name}"
				
			model.create recieved, (err, created)->

				if err
					return completeCall
						httpStatus: 500
						metadata:
							error: err
				
				result[name] = created
				result.metadata = 
					message: "#{name} successfully created."

				completeCall result

	#//============================================================================

	update = 
		method: 'put'
		path: "/#{name}/:id"
		version: version
		description: "Update a #{name}"
		docURL: '/#{name}Controller#UPDATE_' + name.toUpperCase() + '_ACTION'
		params:
			required: []
			optional: []
		allowedUserKinds: []
		roles: []
		callback: (req, res, completeCall) ->

			result = {}
			
			if req.args[name]?
				recieved = req.args[name]
			else return completeCall
				httpStatus: 500
				metadata:
					message: "You haven't send a #{name}"
			
			query = {}
			query[id_field] = req.params.id

			model.findOneAndUpdate query, recieved, (err, updated) ->

				if err
					return completeCall
						httpStatus: 500
						metadata
							error: err
				if not updated?
					return completeCall
						httpStatus: 500
						metadata:
							message: "Not found #{req.params.id} [#{name}]."

				result[name] = updated

				completeCall result

	#//============================================================================

	destroy = 
		method: 'delete'
		path: "/#{name}/:id"
		version: version
		description: "Destroy a #{name}"
		docURL: '/#{name}Controller#DELETE_' + name.toUpperCase() + '_ACTION'
		params:
			required: []
			optional: []
		allowedUserKinds: []
		roles: []
		callback: (req, res, completeCall) ->
			
			query = {}
			query[id_field] = req.params.id	
			
			model.remove query, (err, deleted)->

				if err
					return completeCall
						httpStatus: 500
						metadata:
							error: err
				if not deleted
					completeCall
						httpStatus: 500
						metadata:
							message: "Cannot delete #{req.params.id} [#{name}] because doesn't exist."
				else
					completeCall
						metadata:
							message: "#{req.params.id} [#{name}] succesfully deleted."

	#//============================================================================


	[get, getAll, create, update, destroy]

module.exports = restifier