config =
	hostname: ""
	port: 5000

	dir: './'

	ssl: {}

	session: {}

	mongodb:
		user: ''	
		pass: ''	
		db: 'Evented'
		host: 'localhost'
		port: '27017'
		uri: ->
			uri = "mongodb://#{@user}:#{@pass}@#{@host}:#{@port}/#{@db}"		
			return uri
	redis:
		host: 'localhost'
		port: '6379'
		options:
			password: ''

	api:
		urlRoot: "/"
		versionPrefix: "v"
		docURL: "http://domain.com/API/doc"
	
#//============================================================================

module.exports = (server) ->
	if server?

		if server.port? 
			config.port = server.port

		if server.dir?
			config.dir = server.dir
		else throw Error("You have to provide the root folder on the 'dir' key in the configuration object.")

		if server.mongo?
			config.mongodb.user = server.mongo.user
			config.mongodb.pass = server.mongo.pass
			config.mongodb.host = server.mongo.host
			config.mongodb.port = server.mongo.port
			config.mongodb.db = server.mongo.db || server.mongo.database
			console.log( config.mongodb.uri() )

		if server.redis?
			config.redis.host = server.redis.host
			config.redis.port = server.redis.port
			config.redis.options.password = server.redis.password

	return config	
	

