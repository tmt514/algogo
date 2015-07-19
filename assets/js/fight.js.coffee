class Fight
  constructor: (@game) ->
    @ui = @game.gameUI.uiFight

  prepare: () ->
    @game.eventPool.addCallback('locationChange', (() ->
      loc = @game.player.currentLocation
      if loc.meta.type == 'pset'
        loc.genMonsterLoop(@game)
      return false
    ).bind(this))
