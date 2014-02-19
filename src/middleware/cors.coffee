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

module.exports = (req, res, next) ->
    if !req.get 'Origin'
        # console.log('NO ORIGIN');
        return next()

    # use "*" here to accept any origin or 'http://localhost:3000' to filter
    res.set('Access-Control-Allow-Credentials', 'true')
    res.set('Access-Control-Allow-Origin', req.get('Origin'))
    res.set('Access-Control-Allow-Methods', 'OPTIONS,GET,PUT,POST,DELETE,ALLOW-ORIGIN')
    res.set('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type')
    # res.set('Access-Control-Allow-Max-Age', 3600)

    if 'OPTIONS' is req.method
        # console.log("OPTIONS")
        return res.send 200

    # console.log("NEXT", req.get('Origin'));
    next()

