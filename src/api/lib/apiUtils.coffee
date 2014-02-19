###
//============================================================================
// Node API
//
// Author: Aitor Oses <aitor.oses@gmail.com>
// Created: 2013/06/09
// Copyright:
//
//============================================================================
###

crypto = require "crypto"
util = require "util"
path = require "path"
fs = require "fs"

errorCodes = require './errorCodes'

exports.forEachFileInFolder = (folder, callback) ->

   fs.readdirSync(folder).forEach (filename) ->

        if filename[0] == '.' then return

        if filename.indexOf(".") >= 0
            filename = filename.substr 0, filename.indexOf(".")

        callback(filename)

exports.fillWithErrorCode = (error, result) ->

    e = errorCodes[error]

    if not result? then result = {}

    if (!e)
        e = errorCodes['unknownErrorCode']
        arguments['2'] = error

    result.httpStatus = e.httpStatus
    result.errorCode = e.errorCode
    msgs = ['userMessage', 'developerMessage'];
    args = []
    for a, i in arguments
        if i == 0 || i == 1 then continue
        args.push(a);


    for msg in msgs
        if typeof e.userMessage is 'function'
            result[msg] = e[msg].apply(undefined, args)
        else result[msg] = e[msg]

    return result

# puts the request argument value inside the passed dictionary,
# but only if the value is defined
exports.setIfArgValuePresent = (req, arg, data, defaultValue, filters) ->
    v = req.args[arg]

    if data
        if v isnt null and v isnt undefined
            data[arg] = v
        else if defaultValue isnt null and defaultValue isnt undefined
            data[arg] = defaultValue

        if filters
            if !util.isArray(filters) then filters = [filters]

            for filter in filters
                if typeof data[arg] is 'string'
                    switch (filter)
                        when 'lowercase' then
                        when 'lc'
                            data[arg] = data[arg].toLowerCase()
                            break
                        when 'uppercase' then
                        when 'uc'
                            data[arg] = data[arg].toUpperCase()
                            break
                        when 'trim' then
                        when 't'
                            data[arg] = data[arg].trim()
                            break
                        when 'lct'
                            data[arg] = data[arg].toLowerCase().trim()
                            break
                        when 'uct'
                            data[arg] = data[arg].toUpperCase().trim()
                            break

# splits a string with a ',' delimited list of values into an array
exports.splitArgsList = (args) ->
    if typeof args isnt "string"
        if util.isArray(args) then r = args;
        else r = [args]
    else
        callback = (s) ->
            return s.trim()
            .filter (s) ->
                return s.length > 0
        r = args.split(',').map(callback)

    return r

#Sort field
buildSort = (req, name, dir) ->
    filter = {}
    if req.args[name]
        f = req.args[name]
        filter[f] = 1
        if req.args[dir]
            d = req.args[dir]
            filter[f] = d

    return filter

exports.buildSortField = (req) ->
    return buildSort(req, 'sortField', 'sortDir')

