class Player
  constructor: (@game) ->
    @coin = 0
    @settings = new Object()
    @tasks = new Object()
    @books = new Object()
    @skills = new Object()
    @locations = new Object()

  addTask: (task) ->
    @tasks[task.id] = task
    task.setPlayer(this)
    @game.eventQueue.insert(new Event("UIPanel",
      ((ui)-> return (e)->ui.uiPanel.update())(@game.gameUI),
      @game.wallTimer.getTime()))
    return this

  addBook: (book) ->
    @books[book.id] = book
    book.setPlayer(this)
    @game.eventQueue.insert(new Event("UIBookStore",
      ((ui)-> return (e)->ui.uiBookStore.update())(@game.gameUI),
      @game.wallTimer.getTime()))
    return this

  addCoin: (nCoin) ->
    @coin += nCoin
    window.game.eventPool.trigger('coin')
    return this

  addLocation: (loc) ->
    @locations[loc.id] = loc
    loc.setPlayer(this)
    @game.eventQueue.insert(new Event("UILocation",
      ((ui)-> return (e)->ui.uiLocation.updateList())(@game.gameUI),
      @game.wallTimer.getTime()))
    return this

  acquireSkill: (skillName) ->
    if @skills[skillName] == undefined
      @skills[skillName] = 1
      @game.addMessage('Skill', "習得技能 #{skillName}！")
      window.game.eventPool.trigger('newSkill', skillName)
    return this

  addSkillExp: (name, exp) ->
    if @skills[name] != undefined
      @skills[name] += exp
    return this
