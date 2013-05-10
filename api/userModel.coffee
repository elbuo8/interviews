crypto = require 'crypto'
ObjectID = (require 'mongodb').ObjectID

class userModel
  constructor: (@users, @tags) ->

  registration: (req, res) =>
    # 1. Check for duplicates in email or username
    # 2. Error messages with feedback
    req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
    #req.body['new'] = true Add this later
    @users.insert req.body, (error, result) -> #result viene en forma de array
      req.session._id = result[0]._id
      res.redirect '/createprofile'

  login: (req, res) =>
    # 1. Feedback for wrong information
    console.log req.body
    @users.findOne {username: req.body.username}, {password:1}, (error, user) ->
      if user is null
        res.redirect '/login'
      req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
      if(req.body.password is user.password)
        req.session._id = user._id
        res.redirect '/createprofile' #modify later
      else
        res.redirect '/login'

  logout: (req, res) =>
    delete req.session._id
    res.redirect '/'

  createProfileView: (req, res) =>
    @tags.find({}).toArray(error, tags) ->
      res.render 'createProfileView', {tags:tags}

  createProfile: (req, res) =>
    console.log req
    #save lo q venga

  editProfilePhoto: (req, res) =>
    #post a aws
    #save link en mongo


  getProfile: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, (error, user) ->
      #console.log user, req.session._id
      res.render 'ProfileView', {user: req.session._id, profile: user}

  auth: (req, res, next) =>
    if req.session._id then next() else res.redirect '/'

module.exports = userModel