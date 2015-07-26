pwds = require('../pwds')

class Secure
  check: (req, res) ->
    if !req.session || req.session.passcode != pwds.passcode
      res.redirect('/login')
      # res.status(403).send('403 Forbidden')
      return false
    return true

module.exports = Secure
