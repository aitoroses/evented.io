mock = require '../mocks/server'
process.server = Evented = mock.server
process.modules = mock.modules

expect = require 'expect.js'
Pubsub = require '../../evented.io/core/Pubsub'
Collection = require '../../evented.io/core/Collection'

describe 'Core/PubSub function', ->

	ioRoutes = mock.ioRoutes
	pub = Pubsub()
	User = new Collection('User')
	
	it 'Should be a Function', ->
		expect(Pubsub).to.be.a("function")

	it 'Should have channels', ->
		expect(pub.channels?).to.be true

	it 'Can publish new subscription to its channel', ->
		publishFn = ->
			User.find({})
		publishName = 'User'

		pub.publish User, publishFn

		subs = pub.channels[User.name]

		expect(subs?).to.be true
		expect(pub.channels.hasOwnProperty(publishName)).to.be true
		expect(pub.channels[publishName]).to.eql publishFn

	it 'On instantiation should subscribe event: suscribe', ->
		expect(ioRoutes['subscribe']?).to.be true

	it 'Subscribe event callback should work as expected', (done) ->
		
		# Retrieve the callback
		call = ioRoutes['subscribe']
		req = {
			sessionID: 'session1234'
			data: {subscribe: 'User'}
			socket: {
				emit: (event, data) ->
					expect(data).to.eql {data: {}, collection: 'User'}
					done()
			}
		}
		# Run the call with our mock subscription data
		call(req)


	it 'On instantiation should subscribe event: user', ->
		expect(ioRoutes['user']?).to.be true

	it 'User event callback should work as expected', (done) ->
		call = ioRoutes['user']
		req = {
			sessionID: 'session1234'
			data: {}
			io: {
				emit: (event, data) ->
					expect(data).to.eql {name: "Aitor"}
					done()
			}
		}
		# Run the call with our mock subscription data
		call(req)

	it 'Fibers should have an userId function property', ->
		expect(process.modules.Fiber.current.userId?).to.be true

	it 'should register an insert:publish_name', ->
		User = process.server.mongodb.models.User
		pub.publish User, ->
			return User.find()
		insertionCallback = ioRoutes['insert:User']
		expect(insertionCallback?).to.be true
		req = {
			data: {user: 'Robert'}
		}
		insertionCallback(req)
		# Check that inserted was broadcasted
		inserted = mock.calls.data['inserted:User']
		expect(inserted).to.eql { user: 'Robert', _id: 'randomId' }

	it 'should register an update:publish_name', ->
		User = process.server.mongodb.models.User
		pub.publish User, ->
			return User.find()
		
		updateCallback = ioRoutes['update:User']
		expect(updateCallback?).to.be true
		req = {
			data: {query: {user: 'Robert'}, data: {lastname: "Lopez"}}
		}
		updateCallback(req)
		# Check that inserted was broadcasted
		updated = mock.calls.data['updated:User']
		expect(updated).to.eql { user: 'Robert', _id: 'randomId', lastname: "Lopez"}











