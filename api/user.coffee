crypto = require 'crypto'
#
# * GET home page.
# 
exports.registration = (req, res) ->
	req.user.password = crypto.createHash('sha1')).update(req.user.password).digest('hex')
	@db.collection 'users', (error, users) ->
		users.insert req.user, (error, result) ->
			#
