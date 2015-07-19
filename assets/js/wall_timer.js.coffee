class WallTimer
  constructor: () ->
    @now = new Date().getTime()
    # debug
    @formula = ((t) -> 100 * (t - @now))
    # @formula = ((t) -> t - @now)

  getTime: () ->
    return @formula(new Date().getTime())
