#= require scheduler
#= require event
#= require wall_timer
#= require player
#= require task
#= require book
#= require monster
#= require location
#= require fight
#= require ui

class Game
  constructor: (@config) ->
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
    @monsterDataPool = new MonsterDataPool()

    @player = new Player(this)
    @gameUI = new GameUI(this)
    @fight = new Fight(this)
    
    window.game = this
    window.wallTimer = @wallTimer

  prepare: () ->
    @taskPool.gen(this)
    @bookPool.gen(this)
    @monsterDataPool.gen(this)
    @locationPool.gen(this)

    @fight.prepare()
    @gameUI.prepare()

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
    @eventPool.trigger('startTask')
    task.begin()
    event = new Event("Task #{id}",
      ((t)-> return (e)->t.update(e))(task),
      @wallTimer.getTime() + task.tick)
    @eventPool.addCallback(['startTask', 'endTask', 'locationChange'], ((event, task) ->
      event.valid = false
      task.forceStop()
      return true).bind(null, event, task))
    @eventQueue.insert(event)

  performBook: (id) ->
    console.log(id)
    book = @player.books[id]
    if book == undefined
      return
    if book.validate() == false
      console.log("cancelled!")
      return
    @eventPool.trigger('startTask')
    book.begin()
    event = new Event("Book #{id}",
      ((t)-> return (e)->t.update(e))(book),
      @wallTimer.getTime() + book.tick)
    @eventPool.addCallback(['startTask', 'endTask', 'locationChange'], ((event, book) ->
      event.valid = false
      book.forceStop()
      return true).bind(null, event, book))
    @eventQueue.insert(event)
    
  performLocation: (id) ->
    @player.setLocation(id)

  addMessage: (name, msg) ->
    @gameUI.uiLogger.log(name, msg)


$(document).ready(() ->
  game = new Game({
    fightTick: 500
  })
  game.prepare()
  game.start()
)
