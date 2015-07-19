class BookPool
  constructor: () ->
    @books = new Object()
  gen: (game) ->
    @books['B1'] = new BookTask('B1', 'C 語言入門經典 第一章 (10)', 15, 1, 600,
                            ((event) ->
                              @player.acquireSkill('C: I/O 基礎')
                              @status = 'done'
                            ),
                            10)
    game.eventPool.addCallback('coin',
      (() ->
        if game.player.coin >= @cost
          game.player.addBook(this)
          return true
        return false
      ).bind(@books['B1']))
