util = require("util");
apiUtils = require('../api/lib/apiUtils');

reqArgsConverter = (req, res, next) ->
    # convert BOOL args values from string to boolean
    for own key, value of req.args
        if req.args.hasOwnProperty(key)
            if key is 'fields'
                if typeof value is 'string'
                    req.args[key] = apiUtils.splitArgsList(value)
            else if value is 'true' then req.args[key] = true
            else if value is 'false' then req.args[key] = false
        
    next();

module.exports = reqArgsConverter;
