#= require scheduler
#= require event
#= require wall_timer
#= require player
#= require task
#= require book
#= require location

class Game
  constructor: () ->
    console.log("Hello!")
    @wallTimer = new WallTimer()
    @eventQueue = new EventQueue(@wallTimer)
    @scheduler = new Scheduler(100,
      ((me) ->
        return () ->
          me.eventQueue.executeAll()
      )(this)
    )
    @eventPool = new EventPool()
    @taskPool = new TaskPool()
    @bookPool = new BookPool()
    @locationPool = new LocationPool()

    @player = new Player(this)
    @gameUI = new GameUI(this)
    
    window.game = this
    window.wallTimer = @wallTimer

  prepare: () ->
    @taskPool.gen(this)
    @bookPool.gen(this)
    @locationPool.gen(this)

  start: () ->

    @player.addTask(@taskPool.tasks['T1'])
           .addLocation(@locationPool.locations['L1'])

    console.log("Game Start!")
    @scheduler.start()
    @gameUI.start()

  performTask: (id) ->
    # TODO: should validate 
    console.log(id)
    task = @player.tasks[id]

    if task == undefined
      return
    task.begin()
    @eventQueue.insert(new Event("Task #{id}",
      ((t)-> return (e)->t.update(e))(task),
      @wallTimer.getTime() + task.tick))

  performBook: (id) ->
    console.log(id)
    book = @player.books[id]
    if book == undefined
      return
    if book.validate() == false
      console.log("cancelled!")
      return
    book.begin()
    @eventQueue.insert(new Event("Book #{id}",
      ((t)-> return (e)->t.update(e))(book),
      @wallTimer.getTime() + book.tick))
    
  performLocation: (id) ->
    @addMessage('Location', "前往 #{@player.locations[id]}！")

  addMessage: (name, msg) ->
    @gameUI.uiLogger.log(name, msg)

class GameUI
  constructor: (@game) ->
    @uiStatus = new GameUIStatus(this, @game.player)
    @uiPanel = new GameUIPanel(this, @game.player)
    @uiBookStore = new GameUIBookStore(this, @game.player)
    @uiLogger = new GameUILogger()
    @uiLocation = new GameUILocation(this, @game.player)

  prepare: () ->
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
    $('#locationSelect').change(() ->
      val = $('#locationSelect').val()
      console.log(val)
      window.game.performLocation(val)
    )
  updateList: () ->
    select = $('#locationSelect')
    options = ""
    for key in Object.keys(@player.locations)
      loc = @player.locations[key]
      console.log(loc)
      options += "<option value='#{loc.id}'>#{loc.name}</option>"
    select.html(options)

class GameUIFight
  constructor: () ->
    @boss = null

class GameUILogger
  constructor: () ->
  log: (name, log) ->
    $("<p>[#{name}] #{log}</p>").prependTo($('#logview'))

$(document).ready(() ->
  game = new Game()
  game.prepare()
  game.start()
)
