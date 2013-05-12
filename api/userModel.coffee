crypto = require 'crypto'
ObjectID = (require 'mongodb').ObjectID
gravatar = require 'gravatar'
fs = require 'fs'
amazonS3 = require 'awssum-amazon-s3'
s3 = new amazonS3.S3 {
  accessKeyId: process.env.aws_key,
  secretAccessKey: process.env.aws_secret,
  region: amazonS3.US_EAST_1
}

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
      if result
        res.send {status: 200}
      else
        res.send {status: result}

  getPhoto: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, {photo:1}, (error, user) ->
      res.send user.photo

  setPhoto: (req, res) =>
    console.log req.files
    fs.stat req.files.file.path, (error, fileInfo) =>
      stream = fs.createReadStream req.files.file.path
      options =
        BucketName: 'skedit',
        ObjectName: req.session._id,
        ContentLength: fileInfo.size,
        Acl: 'public-read'
        Body: stream

      s3.PutObject options, (error, data) =>
        if data.StatusCode == 200
          url = 'https://s3.amazonaws.com/skedit/' + req.session._id
          res.send {status: 200, url: url}
          @users.update {_id: new ObjectID req.session._id}, {$set:{photo: url}}, (error, result) ->
        else
          res.send {status: data.StatusCode}



  getProfile: (req, res) =>
    @users.findOne {_id: new ObjectID req.session._id}, (error, user) ->
      #console.log user, req.session._id
      res.render 'ProfileView', {user: user}

  auth: (req, res, next) =>
    if req.session._id then next() else res.redirect '/'

module.exports = userModel