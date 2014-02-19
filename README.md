# Evented.IO

Evented.IO is a Node.JS module that provides a structured way of building RESTful API servers in combination with Websockets (Using Socket.IO) writen in CoffeScript.

The reason why I've created Evented.IO is because I like another framework called MeteorJS, but meteor is a full-stack framework. I needed the flexibility of an express.js server with the ease of use of a MeteorJS Server.

Also, Evented.IO provides a client-server JavaScript API to work with collections in realtime, in Meteor flavor. The API will result familiar to you even if you have used Firebase.

I wanted to construct AngularJS applications and mobile native applications using those kind of API's and being compleit enough to make whatever you want, having all control over your server.

I've used **deployd** for example, but I don't like the idea of for example, can't login by default using an OAuth provider. You have to figure out how to implement it. Evented.IO is compatible with everything, so you can implement it your way maybe using.... ¿Passport?

That said, let's provide a little of light over the table.

## How to Install

In order to instantiate a new server you need to have running an instance of **MongoDB** and another of a **Redis** store

## Configure a new server


```
evented = require 'evented.io'

Evented = evented({port: 5000});
```

## Models and Controllers
You should have 2 folders on your server's root directory:

- 'models' directory
- 'controllers' directory

Checkout the examples to know how to write new models and controllers to create RESTful routes

### Creating a new model

This is not the real User model implementation, we need password salting and those things, but this will give you an idea. Default Modules are loaded into ```process.modules```

This is the default schema for a model.

```
 # Model Structure

 mongoose = process.modules.mongoose
 validate = process.modules.validate

 animalSchema = mongoose.Schema
  
   name:
      type: String
      required: true
      unique: true
      validate: validate('len', 5, 10)

   kind:
      type: String
      required: true
      enum: ['cat', 'dog']

 # Animal model
 module.exports = mongoose.model('Animal', animalSchema);  
 ```
 
### Creating a new controller

```
 # Animals controller

 Animal = process.server.mongodb.models.Animal

 getAllAnimals =
    method: 'get'
    path: "/animal"
    version: 1 # Here we specify the version http://api.server.com/v1/animals
    description: 'Get all Animals'
    docURL: '/AnimalController#GET_ALL_ANIMAL_ACTION' # Documentation URL
    params:
    	# you can specify required or optional fields
        required: [] 
        optional: []
        
    # Also allowed user kinds and roles
    allowedUserKinds: []
    roles: []
    callback: (req, res, completeCall) ->

        Animal
        .find()
        .exec (err, animals)->

            if err
                return next
                	 # Send this data structure
                    httpStatus: 500 # There was an error
                    metadata: err

            completeCall({animals: animals})
            
 module.exports = ->
 	
 	# Here is where we export our Restfull API's
 	
 	[getAllAnimals]
```

## Custom Databases

To use custom databases into your server do the next thing:

Your ```node index.js```

```
Evented = evented({
  port: 5000,
  mongo: {
    host: 'localhost'
    password: '27017'
    db: 'testdb'
    user: ''
    password: ''
  },
  redis: {
    host: 'localhost'
    port: '6379'
    password: ''
  }
});
```

## Configure a new client

You should use this two scripts in your header

```
<head>
	<script src="socket.io/socket.io.js"></script>
	<script src="evented.js"></script>
</head>
```

# TODO

- Describe API
- UserCollection documentation
- Evented API
- Collections
- Pub/Sub
- process new API's (server, redis, mongoDB, etc...)
- Evented.Collection
- Evented.Collections
- Evented.suscribe
- Evented.publish