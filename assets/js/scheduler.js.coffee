
class Scheduler
  constructor: (@tick, @callback) ->

  start: () ->
    console.log("set timeout", @tick)
    func = (p, f) ->
      return () ->
        p.callback()
        window.setTimeout(f(p, f), p.tick)

    window.setTimeout(func(this, func), @tick)

