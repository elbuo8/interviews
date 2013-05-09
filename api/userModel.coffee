crypto = require 'crypto'
ObjectID = (require 'mongodb').ObjectID

class userModel
  constructor: (@users) ->

  registration: (req, res) =>
    # 1. Check for duplicates in email or username
    req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
    @users.insert req.body, (error, result) -> #result viene en forma de array
      req.session._id = result[0]._id
      res.redirect '/editprofile'

  login: (req, res) =>
    console.log req.body
    @users.findOne {username: req.body.username}, {password:1}, (error, user) ->
      if user is null
        res.redirect '/login'
      req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
      if(req.body.password is user.password)
        req.session._id = user._id
        res.redirect '/profile'
      else
        res.redirect '/login'

  logout: (req, res) =>
    delete req.session._id
    res.redirect '/'

  editProfileView: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, {password: 0}, (error, user) ->
      res.render 'editProfileView', {user: user}


  getProfile: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, (error, user) ->
      #console.log user, req.session._id
      res.render 'ProfileView', {user: req.session._id, profile: user}

  auth: (req, res, next) =>
    if req.session._id then next() else res.redirect '/'

module.exports = userModel