express = require('express')
app = express.Router()
uuid = require('node-uuid')

app.get('/something',
  (req, res) ->
    res.json({a: 100, b: 'test'})
)

app.get('/', (req, res) ->
  req.session.seed = uuid.v1()
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
Location = new (require('../models/location'))()
MonsterData = new (require('../models/monster_data'))()
Skill = new (require('../models/skill'))()
Item = new (require('../models/item'))()
Info = new (require('../models/info'))()

models = {
  task: Task
  location: Location
  monster_data: MonsterData
  skill: Skill
  item: Item
  info: Info
}

console.log(Location)

# data index
app.get('/:tblname', (req, res) ->
  if !req.session
    res.status(401).send('Forbidden')
    return
  name = req.params.tblname
  if name == "location"
    models[name].get(((req, res, tblname, err, rows) ->
      res.json(rows)
    ).bind(null, req, res, name),
    [],
    '',
    "")
  else if models[name]
    models[name].get(((req, res, tblname, err, rows) ->
      res.json(rows)
    ).bind(null, req, res, name),
    [],
    '',
    "category = 'task'")
  else
    res.status(404).send('Table name is not recognized.')
)

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
