crypto = require 'crypto'
passport = require 'passport'
LocalStrategy = (require('passport-local')).Strategy

###
Todo:
Handle multiple registrations (duplicate emails)
###

exports.registration = (req, res) ->
  req.body.password = crypto.createHash('sha1').update(req.body.password).digest('hex')
  @db.collection 'users', (error, users) ->
    users.insert req.body, (error) ->
      if not error
        res.send("OK")
        

###
passport.use new LocalStrategy (username, password, done) ->
    User.findOne { username: username }, function(err, user) ->
      if (err) { return done(err); }
      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!user.validPassword(password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user)
###