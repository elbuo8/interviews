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

rtg   = (require("url")).parse(process.env.REDISTOGO_URL);
redis = (require("redis")).createClient(rtg.port, rtg.hostname);

redis.auth(rtg.auth.split(":")[1]);
app = express()

RedisStore = (require('connect-redis'))(express)

app.configure () ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser 'aloha'
  app.use express.session { secret: 'aloha', store : new RedisStore {
    host : rtg.hostname,
    port : rtg.port,
    db: rtg.auth.split(':')[0],
    pass: rtg.auth.split(':')[1]
    }}

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

            app.post "/registration", user.registration
            app.get "/login", (req, res) -> res.render('login')
            app.post "/login", user.login
            app.get '/logout', user.logout
            app.get '/', (req, res) ->
              if req.session._id then res.redirect '/profile' else res.render('index', {user: req.session._id})
            app.get '/profile', user.auth, user.getProfile
            app.get '/createprofile', user.auth, (req, res) ->
              db.collection 'tags', (error, collection) ->
                collection.distinct 'tag', (error, tags) ->
                  res.render 'createProfileView', {tags : tags}

            app.get '/tags', (req, res) ->
              db.collection 'tags', (error, collection) ->
                collection.distinct 'tag', (error, tags) ->
                  res.json {tags : tags}
            app.get '/createprofile', user.auth, user.createProfile
            app.post '/createprofile', user.auth, user.createProfile
            app.get '/user/photo', user.auth, user.getPhoto
            app.post '/user/photo', user.auth, user.setPhoto
            app.post '/user/addskill', user.auth, user.addSkill
            app.post '/user/sethours', user.auth, user.setHours
            app.get '/finder', user.auth, user.getFinder
            app.post '/finder', user.auth, user.getFinderResults
            app.post '/invite', user.auth, user.sendInvite

        else
          console.log error

app.configure "development", ->
  app.use express.errorHandler()

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
