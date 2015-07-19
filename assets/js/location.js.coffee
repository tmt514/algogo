class Location
  constructor: (@id, @name, @meta) ->
    @probWeightList = new Array()
    @weightSum = 0

  setPlayer: (@player) ->

  addProblem: (problem, probability) ->
    @probWeightList.push({p:probability, problem:problem})
    @weightSum += probability

class Room extends Location
  constructor: (id, name) ->
    super(id, name, {type: 'room'})

class ProblemSet extends Location
  constructor: (id, name) ->
    super(id, name, {type: 'pset'})

class LocationPool
  constructor: () ->
    @locations = new Object()

  gen: (game) ->
    @locations['L1'] = new Room('L1', 'R217')
