module.exports = (config) ->

	require './logo'

	express = require 'express.io'
	app = express()
	app.http().io()

	process.server = app
	process.modules = require('./modules')

	# Passport
	passport = process.modules.passport

	# Configure the app
	apiManager = require './api/apiManager'
	app.logger = require './logger'
	app.express = express
	app.config = require( './config' )(config)

	# MongoDB
	initMongoDB = require './mongodb'

	# Redis
	redis = require('redis').createClient(app.config.redis.port, app.config.redis.host)
	app.redis = redis
	RedisStore = require("connect-redis")(express);
	app.store = new RedisStore 
		host: app.config.redis.host
		port: app.config.redis.port
		client: redis


	reqArgsMixer = require "./middleware/reqArgsMixer"
	reqArgsConverter = require "./middleware/reqArgsConverter"
	cors = require "./middleware/cors"

	app.disable('x-powered-by');
	app.enable('trust proxy');

	app.configure ->
		initMongoDB(app)

		app.use express.logger('dev')
		app.use express.json()
		app.use express.urlencoded()
		app.use express.cookieParser()
		app.use reqArgsMixer
		app.use reqArgsConverter
		app.use express.methodOverride()
		app.use express.session 
			secret: 'keyboard cat'
			store: app.store
		app.use passport.initialize()
		app.use passport.session()
		app.use express.compress()
		app.use express.static app.config.dir + '/client'
		app.all '*', cors
		app.use app.router

		# Start the API
		app.apiManager = new apiManager(app)

		# Evented.IO core load
		evented = require './evented.io/core'
		app.evented = evented
		evented.server = app
		evented.io = app.io
		app.use (req, res, next) ->
			process.modules.Fiber(-> next() ).run()

	# Listening
	app.listen process.env.PORT || app.config.port, (err) ->
			app.logger.log 'info', "Listening on port #{process.env.PORT || app.config.port} and process id is #{process.pid}"

	return app.evented