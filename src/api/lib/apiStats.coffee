
module.exports = (app) ->

	redis = app.redis

	redis.on "error", (err) ->
		console.log "Error #{err}"
	
	redis.on "ready", (err) ->
		app.logger.info("Redis is connected.")
	
	redis.auth(app.config.redis.options.password, -> app.logger.info('Redis is authenticated.'))
		
	stats =
		inc: (collection, field, value) ->
			if not value? then value = 1
			redis.hincrby(collection, field, value, undefined)
		collections:
			total: 'total'
			api: 'api'
