
###
API DEFINITION data structure

var API = {
    method: 'get',
    path: "/users",
    version: 2,
    description: 'Get a list of all users.',
    docURL: "/PATH/TO/DOCS",
    allowedUserKinds: ["USER", "KINDS"],
    roles: ["ROLE1", "ROLE2", {'partner':["ROLE4", ...]}],
    params: {
        'required': ["REQUIRED", "PARAMETERS", {"customer":["REQ1", ...]}, ["ONE", "OR", "ANOTHER"]],
        'optional': ["OPTIONAL", "PARAMETERS"]
    },
    callback: function (req, res, next) {
        // THE API IMPLEMENTATION
    },
    stubData: "KEY:DOT.DELIMITED.KEY" || {DATA} || FUNCTION(api, res),
};
###

util = require "util"
fs = require "fs"
path = require "path"
EventEmitter = require('events').EventEmitter

authCodes = require './lib/authCodes'
errorCodes = require "./lib/errorCodes"
httpCodes = require "./lib/httpCodes"
apiUtils = require './lib/apiUtils'


apiManager = (app) ->

    self = this
    EventEmitter.call(self)

    fail = (msg) ->
        app.logger.log("error", "%s. Exiting...", msg);
        process.exit()

    # Control permissions, stub data, etc. before performing API call.
    apiWrapper = (api) ->
        return (req, res) ->
            timeStart = process.hrtime()
            code = null
            result = {}

            #self.emit('apiCallStart', api, req, res, result)
            if req.args.describe_api == true
                result.httpStatus = httpCodes.success
                result.apiDescription =
                    description: api.description
                    docURL: self.config.docURL + api.docURL
                    params: api.params
                    allowedUserKinds: api.allowedUserKinds
                    roles: api.roles
                    returns: null #NOT USED

            # user kinds
            kind = authCodes.userKind.anonymous
            if !result.httpStatus && api.allowedUserKinds && api.allowedUserKinds.length
                if req.user then kind = req.user.kind
                if api.allowedUserKinds.indexOf(kind) < 0
                    apiUtils.fillWithErrorCode 'invalidUserKind', result, api.allowedUserKinds

            # user roles
            if !result.httpStatus && api.roles && api.roles.length
                b = false
                forAllKindsChecked = false
                forKindChecked = false

                if req.user
                    for role in req.user.roles
                        for apiRole in api.roles
                            if typeof apiRole is 'string'
                                forAllKindsChecked = true
                                if role is apiRole
                                    b = true
                                    break
                            else if typeof apiRole is 'object' and apiRole[req.user.kind]
                                forKindChecked = true
                                if apiRole[req.user.kind].indexOf(role) >= 0
                                    b = true
                                    break
                        if b then break
                if forAllKindsChecked or forKindChecked && !b
                    apiUtils.fillWithErrorCode 'userNotInRole', result, api.roles

            # required params
            if !result.httpStatus and api.params.required.length
                stop = false
                for required in api.params.required
                    if util.isArray required
                        foundOne = false
                        for args in required
                            if(req.args[args] isnt undefined)
                                foundOne = true
                                break
                        if foundOne is false
                            stop = true
                            apiUtils.fillWithErrorCode 'requiredParameterIsMissing', result, required.join(' | ')
                            break
                    else if typeof required is 'object' && required[kind]
                        zk = required[kind]
                        for zp in zk
                            if req.args is undefined
                                stop = true
                                apiUtils.fillWithErrorCode 'requiredParameterIsMissing', result, zp
                                break
                    else if req.args[required] is undefined
                        apiUtils.fillWithErrorCode 'requiredParameterIsMissing', result, required
                        stop = true

                    if stop then break


            # limit and offset
            if req.args.limit?
                req.args.limit = parseFloat req.args.limit

            if req.args.offset?
                req.args.offset = parseFloat req.args.offset

            if req.args.sortField?
                req.args.sortField = req.args.sortField.trim()

            if req.args.sortDirection?
                req.args.sortDirection = req.args.sortDirection.toLowerCase()

#            if req.args.groupField?
#                req.args.groupField = req.args.groupField.trim()

#            if req.args.groupDirection?
#                req.args.groupDirection = req.args.groupDirection.toLowerCase()

            # config
            if api.config
                if api.config.requireLimit
                    if req.args.limit is null then req.args.limit = self.config.defaultLimit
                    if rea.args.offset is null then req.args.limit = self.config.defaultOffset

            # Utils for async calls
            completeAPICall = (result) ->
                self.stats.inc(self.stats.collections.total, "calls:active", -1)
                self.stats.inc(self.stats.collections.api, api.apiId + ":calls:active", -1)

                completeCall(result)


            completeCall = (result) ->

                # by default we assume that the call was successful
                if not result.httpStatus? then result.httpStatus = httpCodes.success

                # success flag
                if result.httpStatus is httpCodes.success then result.success = true
                else result.success = false

                # metadata
                if !result.metadata
                    result.metadata = {}
                apiUtils.setIfArgValuePresent req, "limit", result.metadata
                apiUtils.setIfArgValuePresent req, "offset", result.metadata
                apiUtils.setIfArgValuePresent req, "fields", result.metadata
                apiUtils.setIfArgValuePresent req, "sortField", result.metadata
                apiUtils.setIfArgValuePresent req, "sortDirection", result.metadata

                # response http code
                code = result.httpStatus
                if req.args.suppress_response_codes is yes and code isnt httpCodes.success
                    code = httpCodes.success

                # lets go!
                result = JSON.stringify(result)
                res.status(code)

                # JSONP support
                if req.args.callback
                    result = "#{req.args.callback}(#{result})"

                # right now we always return JSON data.
                res.header('Content-Type', 'application/json');
                res.header('Charset', 'utf-8');
                res.write(result);
                res.end();

            if !result.httpStatus
                self.stats.inc(self.stats.collections.total, "calls:count")
                self.stats.inc(self.stats.collections.total, "calls:active")
                self.stats.inc(self.stats.collections.api, api.apiId + ":calls:count")
                self.stats.inc(self.stats.collections.api, api.apiId + ":calls:active")

                if(req.args.return_stub_data is yes)
                    # stub data
                    apiStubData(api, completeAPICall)
                else
                    # call the api
                    api(req, res, completeAPICall)
            else
                completeAPICall(result)


            timeTot = process.hrtime(timeStart)[1] # expressed in ns
            self.stats.inc(self.stats.collections.total, "calls:time", timeTot)
            self.stats.inc(self.stats.collections.api, api.apiId + ":calls:time", timeTot)


    # Register all APIs defined in module with given name.
    # Modules must be in the same folder of this file.
    registerAPI = (name, local) ->
        try
            if local then apiController = require "./#{name}"
            else apiController = require "#{app.config.dir}/controllers/#{name}"
        catch err
            app.logger.log "API require error for controller:", name, err
            throw err

        if typeof apiController isnt "function"
            app.logger.error "Invalid API controller: #{name}. Must be a function"

            if app.isInProduction then process.exit()
            else return

        apiDefs = apiController(app)
        if !util.isArray(apiDefs)
            app.logger.error("Invalid API definitions for API: #{name}. Must be a list of API defs.")

            if app.isInProducition then process.exit()
            else return

        for apiDef in apiDefs
            apiCall = apiDef.callback
            apiCall.apiManager = self
            apiCall.description = apiDef.description
            apiCall.allowedUserKinds = apiDef.allowedUserKinds
            apiCall.roles = apiDef.roles
            apiCall.params = apiDef.params
            apiCall.config = apiDef.config
            if !apiCall.params then apiCall.params = {}
            if !apiCall.params.required then apiCall.params.optional = []
            if !apiCall.params.optional then apiCall.params.optional = []

            apiCall.stubData = apiDef.stubData
            apiCall.docURL = apiDef.docURL
            if !apiCall.docURL then apiCall docURL

            # http method checks
            apiCall.method = apiDef.method
            if !apiCall.method
                fail("API could not be registered because of missing method", apiDef)

            apiCall.method = apiCall.method.toLowerCase()

            # fix api root backslashes
            apiRoot = self.config.urlRoot
            if apiRoot[apiRoot.length - 1] isnt '/'
                apiRoot = apiRoot + '/'

            # fix api path backslashes
                if apiDef.path and apiDef.path[0] != '/'
                    apiDef.path = '/' + apiDef.path

            # format url
            apiCall.apiURL = util.format(
                "%s%s%s%s",
                apiRoot,
                self.config.versionPrefix,
                apiDef.version,
                apiDef.path
            )

            apiCall.apiId = util.format("%s:%s", apiCall.method, apiCall.apiURL)

            app[apiCall.method](apiCall.apiURL, apiWrapper(apiCall))

            app.logger.log("info", "Registered API:", apiCall.method, apiCall.apiURL)

    #-----------------------------------------------------------------

    self.stats = require('./lib/apiStats')(app)
    app.stats = self.stats
    self.stats.inc(self.stats.collections.total, "apiServer:started")
    self.config = app.config.api

    ###
    APIInfo = app.mongodb.model "APIInfo"



    ###
    app.logger.log("info", "Registering APIs...")

    apiUtils.forEachFileInFolder(path.join(app.config.dir, "/controllers"), registerAPI)
    registerAPI 'user/userController' , true
    registerAPI 'user/authController' , true

    app.logger.log("info", "All APIs registered.")


util.inherits(apiManager, EventEmitter)

module.exports = apiManager


