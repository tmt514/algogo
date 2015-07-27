now = () ->
  return (new Date()).toLocaleTimeString()

logger =
  error: (msg...) ->
    console.log("#{now()} [ERROR] - " + JSON.stringify(msg))
  debug: (msg...) ->
    console.log("#{now()} [DEBUG] - " + JSON.stringify(msg))
  info: (msg...) ->
    console.log("#{now()} [INFO] - " + JSON.stringify(msg))
    

module.exports = logger
