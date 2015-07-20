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

  update: () ->
    if @div == null
      @div = $("<div id='#{@task.id}'></div>")
        .append("<button onclick='window.game.perform#{@taskType}(\"#{@task.id}\")'>#{@task.name}</button>")
        .append("<span class='current'>0</span>")
        .append("<span>/</span>")
        .append("<span class='total'>100</span>")
        .append("<span class='status'></span>")
        .appendTo($("#panel#{@taskType}"))

    if @task.status == 'go'
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
      if book.ui == null
        @uiBookList[key] = new GameUITask(null, book, "Book")
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
              $('.tab-panel').not(panel).addClass('hidden')
              $(panel).removeClass('hidden')
              if ui != null
                ui.gameUI.game.eventQueue.insert(new EventNow("UIAchievement",
                  ((ui) -> ui.update()).bind(null, ui)))
            )
    )
      
class GameUIAchievement
  constructor: (@gameUI, @player) ->
  update: () ->

class GameUIItem
  constructor: (@gameUI, @player) ->
    @bookShelf = new GameUIItemBookShelf(@gameUI, @player)
  update: () ->
    @bookShelf.update()

class GameUIItemBookShelf
  constructor: (@gameUI, @player) ->
    @div = $('#bookShelf')
    @bookList = new Object()
  buildNewBook: (book) ->
    $("<div>#{book.name}</div>").addClass('bookThumb')
      .appendTo(@div)
  update: () ->
    for key in Object.keys(@bookList)
      if @player.books[key] == undefined
        @bookList[key].remove()
        delete @bookList[key]
    for key in Object.keys(@player.books)
      if @bookList[key] == undefined
        @bookList[key] = @buildNewBook(@player.books[key])
