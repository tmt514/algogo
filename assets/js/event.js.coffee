#= require wall_timer

class EventPool
  constructor: () ->
    @pool = new Object()

  addCallback: (category, callback) ->
    if @pool[category] == undefined
      @pool[category] = new Array()
    @pool[category].push(callback)

  trigger: (category, data) ->
    if @pool[category] != undefined
      callbacks = @pool[category]
      @pool[category] = []
      for f in callbacks
        if f(data) == false # unsuccessfully done
          @pool[category].push(f)

class Event
  constructor: (@name, @callback, @executeTime) ->

class RepeatingEvent extends Event
  constructor: (@name, @_callback, @executeTime, @tick) ->
    @callback = ((event) -> return (e) ->
      event._callback()
      event.executeTime = window.wallTimer.getTime() + event.tick
    )(this)

class EventQueue
  constructor: (@wallTimer) ->
    @queue = new Array()

  insert: (event) ->
    @queue.push(event)

  executeAll: () ->
    currentTime = @wallTimer.getTime()
    @oldQueue = @queue
    @queue = new Array()
    for event in @oldQueue
      if event.executeTime <= currentTime
        console.log(event)
        event.callback(event)
      # console.log("event time = ", event.executeTime)
      # an event can modify its executeTime to be enqueued again
      if event.executeTime > currentTime
        @queue.push(event)
