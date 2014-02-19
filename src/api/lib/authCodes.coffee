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

authCodes =
	
	userKind:
		anonymous: 'anonymous'
		normal: 'normal'
		administrator: 'administrator'

	userRole:
		normal: 'normal'
		administrator: 'administrator'

	userPermission:
		get: 'get'
		create: 'create'
		update: 'update'
		del: 'delete'

module.exports = authCodes
