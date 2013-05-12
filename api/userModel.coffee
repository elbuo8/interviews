crypto = require 'crypto'
ObjectID = (require 'mongodb').ObjectID
gravatar = require 'gravatar'

class userModel
  constructor: (@users) ->

  registration: (req, res) =>
    console.log req.body
    @users.findOne {$or:[email:req.body.email, username:req.body.username]}, (error, result) =>
      if !result
        req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
        req.body.photo = gravatar.url(req.body.email, {s: '200'})
        @users.insert req.body, (error, result) -> #result viene en forma de array
          req.session._id = result[0]._id
          res.send '200'
      else
        res.send 'Existing username or email'

  login: (req, res) =>
    @users.findOne {username: req.body.username}, {password:1}, (error, user) ->
      if user is null
        res.redirect '/login'
      req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
      if(req.body.password is user.password)
        req.session._id = user._id
        res.redirect '/createprofile' #modify later
      else
        res.send 'Incorrect combination of unsername & password'

  logout: (req, res) =>
    delete req.session._id
    res.redirect '/'

  createProfile: (req, res) =>
    @users.update {_id: new ObjectID req.session._id}, {$set: {hours:req.body.hours, skills:req.body.skills}}, (error, result) ->
      console.log result
      res.redirect '/'

  getPhoto: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, {photo:1}, (error, user) ->
      res.send user.photo


  getProfile: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, (error, user) ->
      #console.log user, req.session._id
      res.render 'ProfileView', {user: req.session._id, profile: user}

  auth: (req, res, next) =>
    if req.session._id then next() else res.redirect '/'

module.exports = userModel