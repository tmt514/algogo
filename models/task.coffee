db = require('../db')
Table = require('./table')

class Task extends Table
  constructor: () ->
    @name = 'task'
    @cols = null
    @_getColumns()

  _getColumns: () ->
    db.serialize((() ->
      # get column definition from sqlite
      query = "SELECT sql FROM sqlite_master WHERE tbl_name = '#{@name}' AND type = 'table'"
      db.all(query, (err, rows) ->
          rawColString = rows[0].sql.match('[(]\(.*\)[)]')[1].split(',')
          @cols = []
          for x in rawColString
            y = x.split(' ')
            @cols.push({name: y[0], type: y[1]})
          console.log(@cols)
      )).bind(this))

  columns: () -> return @cols

module.exports = Task
