#Database connection

mongoose = process.modules.mongoose
#logger = require './logger'
fs = require 'fs'

mongodbReconnectTimer = null
eventsBinded = false

initMongoDB = (app) ->

	loadSchemas = ->

		fs.readdirSync(app.config.dir + '/models').forEach (filename) ->
			if filename[0] == '.' then return

			modelName = filename.substr 0, filename.indexOf(".")
			schema = require "#{app.config.dir}/models/#{modelName}"
			schema.app = app

		# Load User schema

		schema = require "./api/user/userCollection"
		schema.app = app

	tryToInitMongoDB = ->

		initMongoDB(app)

	mongoDBReconnect = ->

		app.logger.info 'MongoDB reconnection attempt.'
		clearTimeout mongodbReconnectTimer

		app.mongodb.reconnectionTime += app.config.mongodb.reconnectTimeout
		if app.config.mongodb.reconnectAttemps >= 0 and
			app.mongodb.reconnectionTime > app.config.mongodb. reconnectTimeout * reconnectAttemps
				return app.logger.error "MongoDB reconnect timeout."

		mongodbReconnectTimer = setTimeout(tryToInitMongoDB, app.config.mongodb.reconnectTimeout)

	setup = (err, connection) ->

		if (err)
			app.logger.error 'MongoDB setup error.'
			mongoDBReconnect()

		if (eventsBinded) then return

		app.mongodb.connection.on "error", (err) ->
			app.logger.log "error", "MongoDB error: ", err  if err
			mongoDBReconnect()

		app.mongodb.connection.on "open", ->
			app.logger.log "info", "MongoDB open."
			clearTimeout mongodbReconnectTimer
			app.mongodb.reconnectionTime = 0

		app.mongodb.connection.on "close", (err) ->
			app.logger.log "info", "MongoDB close: ", err  if err
			clearTimeout mongodbReconnectTimer
			app.mongodb.reconnectionTime = 0
			mongodbReconnectTimer = setTimeout(tryToInitMongoDB, app.config.mongodb.reconnectTimeout)

		app.mongodb.connection.on "connecting", ->
			app.logger.log "info", "DB connecting"

		app.mongodb.connection.on "connected", ->
			app.logger.log "info", "DB connected"

		app.mongodb.connection.on "disconnecting", ->
			app.logger.log "info", "DB disconnecting"

		app.mongodb.connection.on "disconnected", ->
			app.logger.log "info", "DB disconnected"

		app.mongodb.connection.on "reconnected", ->
			capp.logger.log "info", "DB reconnected"

		app.mongodb.connection.on "fullsetup", ->
			app.logger.log "info", "DB fullsetup"

		eventsBinded = true
	#//============================================================================

	options = app.config.mongodb.options

	app.mongodb = mongoose.connect app.config.mongodb.uri(), options, setup
	app.mongodb.reconnectionTime = 0

	loadSchemas()

#//============================================================================

module.exports = initMongoDB