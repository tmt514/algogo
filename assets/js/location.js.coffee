#= require constraint_helpers
#= require monster

class Location
  constructor: (@id, @name, @meta, @shouldUnlock, @eventQueueCategories) ->
    @probWeightList = new Array()
    @weightSum = 0

  initializeToEventPool: () ->
    if @shouldUnlock == undefined
      return
    for category in @eventQueueCategories
      window.game.eventPool.addCallback(category,
        (() ->
          if window.game.player.locations[@id] != undefined
            return true
          if @shouldUnlock(window.game.player) == true
            window.game.player.addLocation(this)
            return true
          return false
        ).bind(this)
      )

  setPlayer: (@player) ->

  addProblem: (problem, weightInt) ->
    @probWeightList.push({problem:problem, p:weightInt})
    @weightSum += weightInt

class Room extends Location
  constructor: (id, name, unlock, categories) ->
    super(id, name, {type: 'room'}, unlock, categories)

class ProblemSet extends Location
  constructor: (id, name, pset, unlock, categories) ->
    super(id, name, {type: 'pset'}, unlock, categories)
    for x in pset
      @addProblem(x[0], x[1])

class LocationPool
  constructor: () ->
    @locations = new Object()

  gen: (game) ->
    @locations['L1'] = new Room('L1', 'R217')
    @locations['L2'] = new ProblemSet('L2', '北極熊的冰原',
      [['北極熊大遷徙', 90],
       ['3n+1 Problem', 10]],
      (new ConstraintHasSkills(['C 語言: I/O 基礎'])).build(),
      ['newSkill']
    )

    for key in Object.keys(@locations)
      @locations[key].initializeToEventPool()
