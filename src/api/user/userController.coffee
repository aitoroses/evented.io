apiUtils = require '../lib/apiUtils'

User = null

#//============================================================================

# Create a User

createUser =
    method: 'post'
    path: "/user"
    version: 1
    description: 'Create a user'
    docURL: '/userController#CREATE_USER_ACTION'
    params:
        required: []
        optional: []
    allowedUserKinds: []
    roles: []
    callback: (req, res, completeCall) ->

        if req.args.user?
            user = req.args.user
        else return completeCall
            httpStatus: 500
            metadata:
                message: "You Haven't send a user"

        User.create user, (err, user)->

            if err
                return completeCall
                    httpStatus: 500
                    metadata: err

            completeCall({user: user}, metadata: {message: "User created succesfully."})

#//============================================================================

# Get all User

getAllUser =
    method: 'get'
    path: "/user"
    version: 1
    description: 'Get all users'
    docURL: '/userController#GET_ALL_USER_ACTION'
    params:
        required: []
        optional: []
    allowedUserKinds: []
    roles: []
    callback: (req, res, completeCall) ->

        User
        .find()
        .skip(req.args.offset)
        .limit(req.args.limit)
        .sort(apiUtils.buildSortField(req))
        .exec (err, users)->

            if err
                return completeCall
                    httpStatus: 500
                    metadata: err

            completeCall({users: users})


#//============================================================================

# Get a user

getUser =
    method: 'get'
    path: "/user/:username"
    version: 1
    description: 'Get users from the database'
    docURL: '/userController#GET_USER_ACTION'
    params:
        required: []
        optional: []
    allowedUserKinds: []
    roles: []
    callback: (req, res, completeCall) ->

        username = req.params.username
        User.findOne({username: username}).exec (err, user) ->
            if err
                return completeCall
                    httpStatus: 500
                    error: err
            if not user?
                return completeCall
                    httpStatus: 500
                    metadata:
                        message: 'That user does not exist'

            completeCall(user: user)
#//============================================================================

# Update a user

updateUser =
    method: 'put'
    path: "/user/:username"
    version: 1
    description: 'Updates a user into the database'
    docURL: '/userController#UPDATE_USER_ACTION'
    params:
        required: []
        optional: []
    allowedUserKinds: []
    roles: []
    callback: (req, res, completeCall) ->

        update = req.args.user
        if not update?
            return completeCall
                httpStatus: 500
                metadata
                    message: 'You have to send a user object'

        User.findOne {username: req.params.username}, (err, user) ->
            if err
                return completeCall
                    httpStatus: 500
                    metadata
                        error: err
            if not user?
                return completeCall
                    httpStatus: 500
                    metadata:
                        message: 'User does not exist'

            user.username = update.username
            user.save()
            completeCall
                user: user

#//============================================================================

#export

module.exports = (app) ->

    User = app.mongodb.model "User"

    [
        createUser
        getAllUser
        getUser
        updateUser
    ]






