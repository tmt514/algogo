class GameUI
  constructor: (@game) ->
    @uiStatus = new GameUIStatus(this, @game.player)
    @uiPanel = new GameUIPanel(this, @game.player)
    @uiBookStore = new GameUIBookStore(this, @game.player)
    @uiLogger = new GameUILogger()
    @uiLocation = new GameUILocation(this, @game.player)
    @uiFight = new GameUIFight(this, @game.player)
    @uiTab = new GameUITab(this, @game.player)

  prepare: () ->
    @uiTab.prepare()
    @uiFight.prepare()
    @uiLocation.prepare()
  
  start: () ->
    @game.eventQueue.insert(new RepeatingEvent("UIStatus",
      ((ui)-> return (e)->ui.uiStatus.update())(this),
      @game.wallTimer.getTime(), 1000))

class GameUITask
  constructor: (@div, @task, @taskType) ->
    @task.setUI(this)
    @hasRemoved = false

  remove: () ->
    @hasRemoved = true
    if @div
      @div.remove()

  update: () ->
    if @hasRemoved == false && @div == null
      @div = $("<div id='#{@task.id}'></div>")
        .append("<button onclick='window.game.perform#{@taskType}(\"#{@task.id}\")'>#{@task.name}</button>")
        .append("<span class='current'>0</span>")
        .append("<span>/</span>")
        .append("<span class='total'>100</span>")
        .append("<span class='status'></span>")
        .appendTo($("#panel#{@taskType}"))

    if @task.status == 'go'
      @div.find('button').attr('disabled', true)
    if @task.status == 'stopped'
      @div.find('button').attr('disabled', false)
    if @task.status == 'done'
      @div.find('button').attr('disabled', true)
    @div.find('.current').text(@task.current)
    @div.find('.total').text(@task.total)
    @div.find('.status').text(@task.status)


class GameUIPanel
  constructor: (@ui, @player) ->
    @uiTaskList = new Object()
  update: () ->
    for key in Object.keys(@player.tasks)
      task = @player.tasks[key]
      if task.ui == null
        @uiTaskList[key] = new GameUITask(null, task, "Task")
      @uiTaskList[key].update()

class GameUIStatus
  constructor: (@ui, @player) ->
  update: () ->
    $('#statusBar').html("coin: #{@player.coin}")

class GameUIBookStore
  constructor: (@ui, @player) ->
    @uiBookList = new Object()
  update: () ->
    for key in Object.keys(@player.books)
      book = @player.books[key]
      if book.status != 'done' && book.ui == null
        @uiBookList[key] = new GameUITask(null, book, "Book")
      if book.ui
        @uiBookList[key].update()

class GameUISkill
  constructor: () ->

class GameUILocation
  constructor: (@ui, @player) ->
  prepare: () ->
    console.log("GameUILocation Prepared!")
    $('#locationSelect').change(() ->
      val = $('#locationSelect').val()
      console.log('select = ',val)
      window.game.performLocation(val)
    )
  update: () ->
  updateList: () ->
    select = $('#locationSelect')
    options = ""
    for key in Object.keys(@player.locations)
      loc = @player.locations[key]
      console.log(loc)
      options += "<option value='#{loc.id}'>#{loc.name}</option>"
    select.html(options)

class GameUIFight
  constructor: (@ui, @player) ->
  prepare: () ->
    @ui.game.eventPool.addCallback('locationChange', (() ->
      @clearMonster()
      return true
    ).bind(this))
    
  setMonster: (@monster) ->
  clearMonster: () ->
    @monster = undefined
  update: () ->
    if @monster == undefined
      $('#panelFight').html()
      return
    
    $('#panelFight').html("<h3>#{@monster.name}</h3><p>程式完成度: <span>#{@monster.current}</span> / <span>#{@monster.hp}</span></p>")
      
class GameUILogger
  constructor: () ->
  log: (name, log) ->
    logview = $('#logview')
    if logview.children().length >= 300
      $(':last-child', logview).remove()
    $("<p>[#{name}] #{log}</p>").prependTo($('#logview'))

class GameUITab
  constructor: (@ui, @player) ->
    @uiAchievement = new GameUIAchievement(@ui, @player)
    @uiItem = new GameUIItem(@ui, @player)
  prepare: () ->
    $.each([['#mapTab', '#panelFight', null],
            ['#itemTab', '#panelItem', @uiItem],
            ['#achievementTab', '#panelAchievement', @uiAchievement]],
          (index, value) ->
            [tab, panel, ui] = value
            $(tab).click(() ->
              $('.tab-button.active').not(tab).removeClass('active')
              $(tab).addClass('active')
              $(tab).find('.tab-notice').html('')
              $('.tab-panel').not(panel).addClass('hidden')
              $(panel).removeClass('hidden')
              if ui != null
                ui.gameUI.game.eventQueue.insert(new EventNow("UIAchievement",
                  ((ui) -> ui.update()).bind(null, ui)))
            )
    )
    @uiItem.prepare()
      
class GameUIAchievement
  constructor: (@gameUI, @player) ->
  update: () ->

class GameUIItem
  constructor: (@gameUI, @player) ->
    @bookShelf = new GameUIItemBookShelf(this, @player)
  update: () ->
    @bookShelf.update()
  prepare: () ->
    @gameUI.game.eventPool.addCallback('addItem', (() ->
      if $('#panelItem').hasClass('hidden')
        $('#itemTab .tab-notice').html($('<span>(!)</span>').addClass('text-alert'))
      else
        @update()
      return false
    ).bind(this))
    $('.item-panel-bg').click(() ->
      $('.item-panel-bg').addClass('hidden')
      $('.item-show').addClass('hidden'))
    $('.item-show').click(() ->
      $('.item-panel-bg').addClass('hidden')
      $('.item-show').addClass('hidden'))

class GameUIItemBookShelf
  constructor: (@ui, @player) ->
    @div = $('#bookShelf')
    @bookList = new Object()
  buildNewBook: (book) ->
    $("<div>#{book.name}</div>").addClass('book-thumb')
      .click(((f, book) -> f(book)).bind(null, @showBook, book))
      .appendTo(@div)
  update: () ->
    for key in Object.keys(@bookList)
      if @player.items.books[key] == undefined
        @bookList[key].remove()
        delete @bookList[key]
    for key in Object.keys(@player.items.books)
      if @bookList[key] == undefined
        @bookList[key] = @buildNewBook(@player.books[key])

    if @div.children('.book-thumb').length > 0
      $('#bookShelfTitle').html('My Books')
    else
      $('#bookShelfTitle').html('')
  showBook: (book) ->
    bookInfo = $("<h3>#{book.name}</h3>Meow Meow")
    $('.item-panel-bg').removeClass('hidden')
    $('.item-show').html(bookInfo).removeClass('hidden')
