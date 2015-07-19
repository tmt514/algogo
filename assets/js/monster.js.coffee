class Monster
  constructor: (@name, @hp, @monsterData, @tick) ->
    @status = 'stopped'
    @current = 0
    @ui = null
    @atk = @monsterData.playerAttackFunc
    @rep = @monsterData.replenishFunc
    @done = (() -> )

  setDone: (@done) ->
  setUI: (@ui) ->
    
  update: (event) ->

    if @ui == undefined
      return
    player = window.game.player

    if @status == 'go'
      @status = 'go:atk'
      event.executeTime = window.wallTimer.getTime() + @tick
      @ui.setMonster(this)
      @ui.update()
      return

    if @status == 'done'
      @done()
      return

    if @status == 'win'
      @monsterData.winFunc(player, @monsterData)
      window.game.addMessage('Accepted', "提交「#{@name}」終於 AC 了！")
      @status = 'done'
      event.executeTime = window.wallTimer.getTime() + @tick
      @ui.update()
      return

    if @status == 'go:def'
      def_value = @rep(player, @monsterData)
      if def_value > @current
        def_value = @current
      if def_value > 0
        window.game.addMessage('Fight', "發現了「#{@name}」其中 #{def_value} 行有 Bug，這部份必須重寫。")
        @current -= def_value
        @status = 'go:atk'
        event.executeTime = window.wallTimer.getTime() + @tick
        @ui.update()
        return
      else
        @status = 'go:atk'

    if @status == 'go:atk'
      atk_value = @atk(player, @monsterData)
      if atk_value > @hp - @current
        atk_value = @hp - @current
      window.game.addMessage('Fight', "平淡地對「#{@name}」寫出了 #{atk_value} 行程式...")
      @current += atk_value
      if @current >= @hp
        @current = @hp
        @status = 'win'
      else
        @status = 'go:def'
      event.executeTime = window.wallTimer.getTime() + @tick
      @ui.update()
      return

###
# MonsterData
# @id: ID
# @name: display name, search name
# @hpRange: will generate the monster's health randomly
# @meta: probably have item effects, etc
# @playerAttackFunc: (player, monsterData)
#   calculate everyround
# @replenishFunc: (player, monsterData)
#   calculate everyround
# @winFunc: (player, monsterData)
#   decide what player will get after this fight
#   directly call player's function (e.g. addCoin(), addItem(), addSomething())
###

class MonsterData
  constructor: (@id, @name, @hpRange, @meta, @playerAttackFunc, @replenishFunc, @winFunc) ->
    if Array.isArray(@hpRange) == false
      @hpRange = [@hpRange, @hpRange]
    if @hpRange[0] > @hpRange[1]
      tmp = @hpRange[0]
      @hpRange[0] = @hpRange[1]
      @hpRange[1] = tmp

  gen: (done) ->
    hp = Math.floor((Math.random() * (@hpRange[1] - @hpRange[0] + 1)) + @hpRange[0])
    problem = new Monster(@name, hp, this, window.game.config.fightTick)
    problem.setDone(done)
    problem.setUI(window.game.gameUI.uiFight)
    return problem

class AtkHelper
  @linearSkillExpCalculator: (skillName, coefficient) ->
    return (
      (name, coef, player, mData) ->
        if player.skills[name] == undefined
          return 0
        vatk = Math.ceil(player.skills[name] * coef - mData.meta.adjustAtk)
        if vatk < 0
          vatk = 0
        return vatk
    ).bind(null, skillName, coefficient)

class RepHelper
  @linearSkillExpCalculator: (skillName, coefficient) ->
    return ((name, coef, player, mData) ->
      if player.skills[name] == undefined
        return mData.meta.adjustRep
      vrep = Math.floor(mData.meta.adjustRep - player.skills[name] * coef)
      if vrep < 0
        vrep = 0
      return vrep).bind(null, skillName, coefficient)

class WinHelper
  @addSkillExp: (skillName, exp) ->
    return ((name, exp, player, mData) ->
      player.addSkillExp(name, exp)
    ).bind(null, skillName, exp)

class MonsterDataPool
  constructor: () ->
    @data = new Object()
  get: (name) ->
    return @data[name]
  gen: (game) ->
    @data['M1'] = new MonsterData('M1', '北極熊大遷徙', [16, 23],
      {adjustAtk: 0, adjustRep: 0},
      AtkHelper.linearSkillExpCalculator('C 語言: I/O 基礎', 0.1),
      RepHelper.linearSkillExpCalculator('C 語言: I/O 基礎', 0.1),
      WinHelper.addSkillExp('C 語言: I/O 基礎', 2))
    @data['M2'] = new MonsterData('M2', '3n+1 Problem', [42, 67],
      {adjustAtk: 0, adjustRep: 0},
      AtkHelper.linearSkillExpCalculator('C 語言: I/O 基礎', 0.1),
      RepHelper.linearSkillExpCalculator('C 語言: I/O 基礎', 0.1),
      WinHelper.addSkillExp('C 語言: I/O 基礎', 3))
