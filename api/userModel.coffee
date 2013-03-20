crypto = require 'crypto'

class userModel
  constructor: (@users) ->

  registration: (req, res) =>
    # 1. Check for duplicates in email or username
    req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
    console.log @users
    @users.insert req.body, (error, result) -> #result viene en forma de array 
      req.session._id = result[0]._id
      res.redirect '/'
      
  login: (req, res) =>
    @users.findOne {username: req.body.username}, {password:1}, (error, user) ->
      req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
      if(req.body.password === user.password) 
        req.session._id = user._id
        res.redirect '/'
        
    
module.exports = userModel