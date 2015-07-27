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

models = {
  task: Task
}

console.log(Task)

# model index
app.get('/admin/db/:tblname', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if models[name]
    models[name].get(((req, res, tblname, err, rows) ->
      req.flash('error', err) if err
      res.render('data_show', {
        rows: rows,
        columns: models[name].columns(),
        tblname: tblname,
        formMethod: 'POST',
        data: models[name].defaultValues()
      })
    ).bind(null, req, res, name))
  else
    res.status(404).send('Table name is not recognized.')
)

# create
app.post('/admin/db/:tblname', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if models[name]
    models[name].add(((req, res, name, err) ->
      req.flash('error', err) if err
      res.redirect("/admin/db/#{name}")
    ).bind(null, req, res, name), req.body.data)
  else
    res.status(404).send('Table name is not recognized.')
)

# edit
app.get('/admin/db/:tblname/:id', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if models[name]
    models[name].get(((req, res, tblname, err, rows) ->
      req.flash('error', err) if err
      res.render('data_show', {
        rows: rows,
        columns: models[name].columns(),
        tblname: tblname,
        formMethod: 'PUT',
        data: rows[0],
        dataid: req.params.id,
      })
    ).bind(null, req, res, name),
    [req.params.id],
    "",
    "id = ?")
  else
    res.status(404).send('Table name is not recognized.')
)

# update
app.post('/admin/db/:tblname/:id', (req, res) ->
  return if !secure.check(req, res)
  name = req.params.tblname
  if models[name]
    models[name].update(((res, name) ->
      res.redirect("/admin/db/#{name}")
    ).bind(null, res, name), req.body.data)
  else
    res.status(404).send('Table name is not recognized.')
)

# delete
###
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
###

module.exports = app
