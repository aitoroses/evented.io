#
# Plugin timestamps
#
# FASE ALPHA (No testeado al guardar!!Podria fallar el SAVE)
#

mongoose = require('mongoose')
BinaryParser = require('mongoose/node_modules/mongodb/node_modules/bson').BinaryParser

timestampsPlugin = (schema, options) ->
    # Add timestamps
    schema.add
        createdAt: Date
        updatedAt: Date
    # When create or update the fields update theirs values soo good!! ^
    schema.pre('save', (next) ->
        if (!this.createdAt)
            this.createdAt = this.updatedAt = new Date
        else
            this.updatedAt = new Date
        next()
    )

module.exports = timestampsPlugin