module.exports = Evented = {}

Evented.Collection = require "./Collection"

Pubsub = require('./pubsub')()
Evented.Pubsub = Pubsub
Evented.publish = Pubsub.publish
