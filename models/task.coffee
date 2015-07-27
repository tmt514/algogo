db = require('../db')
Table = require('./table')

class Task extends Table
  constructor: () ->
    @name = 'task'
    @cols = null
    @_getColumns()

  _modifyColumns: () ->
    for x in @cols
      if (x.name == 'messages' or x.name == 'unlock_condition' or
      x.name == 'task_complete' or x.name == 'location_list')
        x.type = 'JSON'

  defaultValues: () ->
    ret = {
      category: 'task',
      id: 'T2',
      total: 10,
      step: 1,
      tick: 1000,
      messages: '{}',
      unlock_condition: '{}',
      task_complete: '{}',
      location_list: '[]',
    }
    return ret
module.exports = Task
