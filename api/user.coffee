crypto = require 'crypto'

exports.registration = (req, res) ->
	req.user.password = crypto.createHash('sha1').update(req.user.password).digest('hex')
	console.log req.user
  @db.collection 'users', (error, users) ->
		users.insert req.user, (error, result) ->
      console.log result
      res.send "ok"