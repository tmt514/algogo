db = require('../db')
Table = require('./table')

class Info extends Table
  constructor: () ->
    @name = 'info'
    @cols = null
    @_getColumns()

  _modifyColumns: () ->
    for x in @cols
      if (x.name == 'unlock_condition' or
      x.name == 'monster_weights')
        x.type = 'JSON'

  defaultValues: () ->
    ret = {
      unlock_condition: '{}',
      monster_weights: '[]',
    }
    return ret
module.exports = Info
