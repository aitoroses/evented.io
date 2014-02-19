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

httpCodes = require './httpCodes'
util = require 'util'

errorCodes = 
    # 400 - Application errorCodes
    invalidUserKind:
        httpStatus: httpCodes.authError
        errorCode: 40101
        userMessage: (kinds) ->
            ""
        developerMessage: (kinds) ->
            util.format "The user must be of one of the following kinds: %s", kinds

    userNotInRole:
        httpStatus: httpCodes.authError
        errorCode: 40102
        userMessage: (roles) ->
            ""
        developerMessage: (roles) ->
            util.format "The user must have one of the following roles: %s", roles
    
    # 500 - server errors
    unknownErrorCode: 
        httpStatus: httpCodes.serverError
        errorCode: 5000
        userMessage: (err) -> 
            ""
        developerMessage: (err) -> 
            util.format("Unknown error code: %s", err)

    # bad request 
    requiredParameterIsMissing: 
        httpStatus: httpCodes.error
        errorCode: 40004,
        userMessage: (paramName) ->
          ""
        
        developerMessage: (paramName) ->
            util.format("Required parameter is missing: %s", paramName)
        
   

module.exports = errorCodes