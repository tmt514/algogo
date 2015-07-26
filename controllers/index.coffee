express = require('express')
app = express.Router()

app.get('/something',
  (req, res) ->
    res.json({a: 100, b: 'test'})
)

app.get('/', (req, res) ->
  res.render('index', {
    title: 'Hey',
    message: 'Hello there!',
  })
)

# Login
app.get('/login', (req, res) ->
  res.render('login')
)

app.post('/login', (req, res) ->
  req.session.passcode = req.body.passcode.substring(0, 10)
  return if !secure.check(req, res)
  res.redirect('/admin')
)

# Secure
secure = new (require('./secure'))()


# Admin
app.get('/admin', (req, res) ->
  return if !secure.check(req, res)
  res.render('admin')
)

# models
db = require('../db')
Task = new (require('../models/task'))()

console.log(Task)

# model index
app.get('/admin/db/:tblname', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if name == 'task'
    Task.get(((res, tblname, rows) ->
      res.render('data_show', {
        rows: rows,
        columns: Task.columns(),
        tblname: tblname,
      })
    ).bind(null, res, name))
  else
    res.status(404).send('Table name is not recognized.')
)

# create
app.post('/admin/db/:tblname', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if name == 'task'
    Task.add(((res, name) ->
      res.redirect("/admin/db/#{name}")
    ).bind(null, res, name), req.body)
  else
    res.status(404).send('Table name is not recognized.')
)

# edit
app.get('/admin/db/:tblname/:id', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if name == 'task'
    Task.get(((res, rows) ->
      res.json(rows)
    ).bind(null, res),
    "",
    "id = #{req.params.id}")
  else
    res.status(404).send('Table name is not recognized.')
)

# update
app.put('/admin/db/:tblname/:id', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if name == 'task'
    Task.add(((res, name) ->
      res.redirect("/admin/db/#{name}")
    ).bind(null, res, name), req.body)
  else
    res.status(404).send('Table name is not recognized.')
)

# delete
app.delete('/admin/db/:tblname/:id', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if name == 'task'
    Task.delete(((res, name) ->
      res.redirect("/admin/db/#{name}")
    ).bind(null, res, name), req.body)
  else
    res.status(404).send('Table name is not recognized.')
)

module.exports = app
