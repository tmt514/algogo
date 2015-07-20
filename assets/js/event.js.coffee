#= require wall_timer

class EventPool
  constructor: () ->
    @pool = new Object()

  addCallback: (category, callback) ->

    # we allow category to be multiple elements
    if Array.isArray(category)
      _others = category.slice(1)
      category = category[0]
      if _others.length > 0
        @addCallback(_others, callback)

    if @pool[category] == undefined
      @pool[category] = new Array()
    console.log('EventPool: added to category ', category)
    @pool[category].push(callback)

  trigger: (category, data) ->
    if @pool[category] != undefined
      callbacks = @pool[category]
      @pool[category] = []
      console.log('triggered: ', category)
      for f in callbacks
        if f(data) == false # unsuccessfully done
          @pool[category].push(f)

class Event
  constructor: (@name, @callback, @executeTime) ->
    @valid = true

class EventNow extends Event
  constructor: (name, callback) ->
    super(name, callback, window.wallTimer.getTime())

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
      # an event may be interrupted and abandoned
      if event.valid == false
        continue
      if event.executeTime <= currentTime
        console.log(event)
        event.callback(event)
      # an event can modify its executeTime to be enqueued again
      if event.executeTime > currentTime
        @queue.push(event)
