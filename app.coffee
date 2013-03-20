require('coffee-script')
require('coffee-trace')
###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
mongo = (require 'mongodb').MongoClient
userModel = require './api/userModel'

app = express()

app.configure () ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  
	# Connect to the db
  mongo.connect process.env.MONGOHQ_URL, (err, db) ->
      db.authenticate process.env.MONGOHQ_USER, process.env.MONGOHQ_PWD, (error) ->
        if not error
          console.log "Connected"
          db.collection 'users', (error, collection) ->
            #Initialize models
            user = new userModel collection
            # Handle user registration
            app.get "/registration", (req, res) -> res.render('registration');
            app.post "/registration", user.registration
            #app.get "/login", (req, res) -> res.render('login')
            #app.post "/login", user.login
            #app.post '/logout', user.logout
          
        else 
          console.log error
  
app.configure "development", ->
  app.use express.errorHandler()

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
