db = require('../db')
logger = require('../lib/logger')

class Table
  constructor: () ->
    @name = null
  
  _getColumns: () ->
    db.serialize((() ->
      # get column definition from sqlite
      query = "SELECT sql FROM sqlite_master WHERE tbl_name = '#{@name}' AND type = 'table'"
      db.all(query, ((err, rows) ->
          rawColString = rows[0].sql.match('[(]\(.*\)[)]')[1].split(',')
          @cols = []
          for x in rawColString
            y = x.split(' ')
            @cols.push({name: y[0], type: y[1]})
          @_modifyColumns()
      ).bind(this))).bind(this))

  # abstract
  _modifyColumns: () ->
  # abstract
  defaultValues: () ->
    return {}
  
  columns: () -> return @cols

  get: (callback, values, select, where, limit, order_by) ->
    if !values then values = []
    if !select then select = 'SELECT * ' else select = 'SELECT ' + select
    if !where then where = '' else where = 'WHERE ' + where
    if !limit then limit = '' else limit = 'LIMIT ' + limit
    if !order_by then order_by = '' else order_by = 'ORDER_BY ' + order_by
    
    query = "#{select} from #{@name} #{where} #{limit} #{order_by}"
    db.serialize(((callback, query, values, name) ->
      logger.info("Query: [#{query}]")
      db.all(query, values, (err, rows) ->
        logger.info("Table #{name} Query retrieve #{rows.length} data.")
        callback(err, rows)
      )
    ).bind(null, callback, query, values, @name))

  add: (callback, obj) ->
    logger.info(obj)
    keys_ = Object.keys(obj)
    masked_values_ = []
    values_ = []
    for e in keys_
      masked_values_.push("?")
      values_.push(obj[e])
    keys_ = keys_.join(', ')
    logger.info(masked_values_)
    masked_values_ = masked_values_.join(', ')

    query_insert = "INSERT INTO #{@name} (#{keys_}) VALUES (#{masked_values_})"

    db.serialize(((c, q, v) ->
      logger.info("Query: [#{q}]")
      db.run(q, v, ((err) ->
        logger.error(err)
        c(err)))
    ).bind(null, callback, query_insert, values_))

  update: (callback, obj) ->
    keys_ = Object.keys(obj)
    masked_values_ = []
    values_ = []
    for e in keys_
      masked_values_.push("#{e}=?")
      values_.push(obj[e])
    masked_values_ = masked_values_.join(', ')
    id = obj['id']

    query_update = "UPDATE #{@name} SET #{masked_values_} WHERE id = ?"
    values_.push(id)

    db.serialize(((callback, query, values) ->
      logger.info("Query: [#{query}]")
      db.run(query, values, ((err) ->
        logger.info(err)
        callback(err)))
    ).bind(null, callback, query_update, values_))


module.exports = Table
