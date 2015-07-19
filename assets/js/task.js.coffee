# status = [stopped, go, done]

class Task
  constructor: (@id, @name, @total, @step, @tick, @done, @begin) ->
    @ui = null #to be set latter
    @status = 'stopped'
    @current = 0
    @meta = new Object()
    @validate = (()->return true)

  setUI: (ui) ->
    @ui = ui

  setGame: (game) ->
    @game = game

  setPlayer: (player) ->
    @player = player

  update: (event) ->
    if @status == 'go'
      @current += @step
      
      if @current >= @total
        @current = @total
        @status = 'done'
        @done(event)
      else
        event.executeTime = window.wallTimer.getTime() + @tick

    @ui.update()

class BasicTask extends Task
  constructor: (@id, @name, @total, @step, @tick, @done) ->
    @ui = null #to be set latter
    @status = 'stopped'
    @current = 0
    @meta = new Object()
    @validate = (()->return true)
    @begin = (() ->
        @status = 'go'
        if @ui
          @ui.update()
      )

class BookTask extends Task
  constructor: (@id, @name, @total, @step, @tick, @done, @cost) ->
    @ui = null #to be set latter
    @status = 'stopped'
    @current = 0
    @meta = new Object()
    @validate = (() -> return @player.coin >= @cost)
    @begin = (() ->
        @status = 'go'
        if @ui
          @ui.update()
      )

class TaskPool
  constructor: () ->
    @tasks = new Object()
  gen: (game) ->
    @tasks['T1'] = new BasicTask('T1', '打掃 R217', 10, 1, 1000,
                            ((event) ->
                              window.game.addMessage('Task Complete', 'R217 打掃完畢!')
                              @player.addCoin(10)
                              @status = 'stopped'
                              @current = 0
                              @ui.div.find('button').attr('disabled', false)
                            ))

