class WallTimer
  constructor: () ->
    @now = new Date().getTime()
    @formula = ((t) -> t - @now)

  getTime: () ->
    return @formula(new Date().getTime())
