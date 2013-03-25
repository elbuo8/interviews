crypto = require 'crypto'
ObjectID = (require 'mongodb').ObjectID

class userModel
  constructor: (@users) ->

  registration: (req, res) =>
    # 1. Check for duplicates in email or username
    req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
    @users.insert req.body, (error, result) -> #result viene en forma de array 
      req.session._id = result[0]._id
      res.redirect '/'
      
  login: (req, res) =>
    @users.findOne {username: req.body.username}, {password:1}, (error, user) ->
      req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
      if(req.body.password is user.password) 
        req.session._id = user._id
        res.redirect '/'
      else
        res.redirect '/login'
        
  logout: (req, res) =>
    delete req.session._id
    res.redirect '/'
    
  editProfile: (req, res) =>
    @users.update {_id: new ObjectID(req.session._id)}, {$set:{profile:req.body}}, (error) ->
      res.send "OK"
      
  getProfile: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, (error, user) ->
      res.render 'profile', {owner: req.session._id, profile: user}
      
  auth: (req, res, next) =>
    if req.session._id then next() else res.render 'main'
    
module.exports = userModel