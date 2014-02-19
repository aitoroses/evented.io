User = null

passport = null

#//============================================================================


login = 
	method: 'post'
	path: "/login"
	version: 1
	description: 'Login with a user'
	docURL: '/authController#POST_LOGIN'
	params:
		required: ['user']
		optional: []
	allowedUserKinds: []
	roles: []
	callback: (req, res, completeCall) ->

		user = req.args.user

		req.body.username = user.username
		req.body.password = user.password

		passport.authenticate('local', (err, user, info) ->

			result = {}
			if err or user is false
				result.metadata = {info: info}
				result.httpStatus = 401
				return completeCall(result)
			req.logIn user, (err) ->
				if err then return completeCall
					httpStatus: 500
					metadata:
						error: err
				result.loggedIn = true
				result.user = {_id: user._id, username: user.username, kind: user.kind}
				result.metadata = {message: 'Logged in.'}
				completeCall result

		)(req, res, completeCall)

loginGET = 
	method: 'get'
	path: "/login"
	version: 1
	description: 'Login with a user'
	docURL: '/authController#GET_LOGIN'
	params:
		required: ['username', 'password']
		optional: []
	allowedUserKinds: []
	roles: []
	callback: (req, res, completeCall) ->

		passport.authenticate('local', (err, user, info) ->

			result = {}
			if err or user is false
				result.metadata = {info: info}
				result.httpStatus = 401
				return completeCall(result)
			req.logIn user, (err) ->
				if err then return completeCall
					httpStatus: 500
					metadata:
						error: err
				result.loggedIn = true
				result.user = {_id: user._id, username: user.username, kind: user.kind}
				result.metadata = {message: 'Logged in.'}
				completeCall result

		)(req, res, completeCall)

#//============================================================================

#

isLoggedIn = 
	method: 'get'
	path: "/logged"
	version: 1
	description: "Check if it's logged in"	
	docURL: '/authController#GET_ISLOGGEDIN_ACTION'
	params:
		required: []
		optional: []
	allowedUserKinds: []
	roles: []
	callback: (req, res, completeCall) ->
		result = {}
		if req.user
			result.user = req.user
			result.loggedIn = true
			result.metadata = {message: "You are logged in."}
		else
			result.loggedIn = false 
			result.metadata = {message: "You are not logged in."}
		completeCall(result)

#

logout = 
	method: 'get'
	path: "/logout"
	version: 1
	description: 'Logout from session.'
	docURL: '/authController#GET_LOGOUT_ACTION'
	params:
		required: []
		optional: []
	allowedUserKinds: []
	roles: []
	callback: (req, res, completeCall) ->
		result = {}
		result.loggedIn = false;
		if req.user?
			req.logout()
			result.metadata = {message: "Logged out succesfully."}
			return completeCall(result)
		
		result.metadata = {message: "You where not logged in."}
		completeCall result


#//============================================================================

# Register a user

register = 
	method: 'post'
	path: "/register"
	version: 1
	description: 'Register a user'
	docURL: '/authController#POST_REGISTER_ACTION'
	params:
		required: ['user']
		optional: []
	allowedUserKinds: []
	roles: []
	callback: (req, res, completeCall) ->
		result = {}
		user = req.args.user
		# if not kind present, we assume normal
		if not user.kind?
			user.kind = 'normal'
			
		# create user
		User.create user, (err, user) ->
			if err
				result.metadata = {error: err}
				result.httpStatus = 500
				return completeCall(result)

			# complete request
			user.kind = user.password = user.__v = undefined
			result.user = user
			result.metadata = {message: "Usuario registrado correctamente."}
			completeCall(result)


#//============================================================================

module.exports = (app) ->
	passport = process.modules.passport
	LocalStrategy = process.modules["passport-local"].Strategy
	User = app.mongodb.model "User"

	passport.use( new LocalStrategy (username, password, done) ->
		User.findOne { username: username }, (err, user) ->
			if err then return done(err)
			if not user then return done null, false, { message: 'Unknown user ' + username }
			user.comparePassword password, (err, isMatch) ->
				if err then return done(err)
				if isMatch
					return done(null, user)
				else
					return done(null, false, { message: 'Invalid password' })
	)

	passport.serializeUser (user, done) ->
		done null, user._id
	
	passport.deserializeUser (id, done) ->
		User.findById id, (err, user) ->
			done(err, user)

	# models		
	User = app.mongodb.model "User"

	return [
		# local auth
		login
		loginGET
		isLoggedIn
		#logout
		logout
		#register
		register
	]