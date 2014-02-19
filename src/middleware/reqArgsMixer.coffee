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


extend = require("node.extend");

reqArgsMixer = (req, res, next) ->

    req.args = {}
    extend(req.args, req.body, req.query)
    next()

module.exports = reqArgsMixer;
