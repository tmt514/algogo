db = require('../db')

class Table
  constructor: () ->
    @name = null

  get: (callback, select, where, limit, order_by) ->
    if !select then select = 'SELECT * ' else select = 'SELECT ' + select
    if !where then where = '' else where = 'WHERE ' + where
    if !limit then limit = '' else limit = 'LIMIT ' + limit
    if !order_by then order_by = '' else order_by = 'ORDER_BY ' + order_by
    
    console.log("Query message = [#{select} from #{@name} #{where} #{limit} #{order_by}]")

    db.serialize(((c,s,n,w,l,o) ->
      console.log("DB Querying!!")
      db.all("#{s} FROM #{n} #{w} #{l} #{o}", (err, rows) ->
        console.log("Table #{n} Query retrieve #{rows.length} data.")
        c(rows)
      )
    ).bind(null, callback, select, @name, where, limit, order_by))

module.exports = Table
