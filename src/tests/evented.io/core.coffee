# Mock up the process
mock = require('../mocks/server')
process.server = mock.server
process.modules = mock.modules

expect = require 'expect.js'
Collection = require '../../evented.io/core/Collection'

describe 'Core/Collection Class', ->

	col = null

	beforeEach () ->
		col = new Collection 'User'
	
	it 'Should be a Class', ->
		expect(Collection).to.be.a("function")
	
	it 'Should have a constructor', ->
		expect(Collection.constructor?).to.be(true)

	it 'Should have a name', ->
		expect(col.name).to.equal 'User'

	it 'Should have a model attached from its process.server mongoose models', ->
		expect(col.model).to.be process.server.mongodb.models.User

	it 'Should be stored on Evented.Collections', ->
		expect(process.server.Collections.User).to.be col

	it 'Should have the find method that return a query to be stored on redis and later execution', ->
		expect(col.find?).to.be true
		expect(col.find({_id: "someId"})).to.eql {collection: 'User', query: {_id: "someId"}}

	it 'Evented.Collections should have only one instance per model', ->
		expect(Object.keys(process.server.Collections).length).to.be 1



	
