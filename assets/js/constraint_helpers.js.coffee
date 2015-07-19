class ConstraintAnd
  constructor: (@arr) ->
  build: () ->
    yarr = []
    for x in @arr
      yarr.push(x.build())
    return ((yarr, player) ->
        for x in yarr
          if x() == false
            return false
        return true
      ).bind(null, yarr)

class ConstraintOr
  constructor: (@arr) ->
  build: () ->
    yarr = []
    for x in @arr
      yarr.push(x.build())
    return ((yarr, player) ->
      for x in yarr
        if x() == true
          return true
      return true
    ).bind(null, yarr)

class ConstraintSingleSkill
  constructor: (@skillName) ->
  build: () ->
    return ((name, player) ->
      return player.skills[name] != undefined
    ).bind(null, @skillName)

class ConstraintHasSkills
  constructor: (@skillList) ->
    @p = []
    if Array.isArray(@skillList) == false
      @skillList = [@skillList]
    for x in @skillList
      @p.push(new ConstraintSingleSkill(x))
  build: () ->
    if @p.length == 0
      return (() -> return true)
    if @p.length == 1
      return @p[0].build()
    return (new ConstraintAnd(@p)).build()

