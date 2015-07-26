
//SQLite3
/****** Initialize database ******/
var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database('data/game.sqlite3');

console.log(db);

db.serialize(function() {
  /* book and task are both using task table*/
  db.run("CREATE TABLE task ("
    + "category STRING," /* TYPE: book, task */
    + "id STRING,"
    + "name STRING,"
    + "total INT,"
    + "step INT,"
    + "tick INT,"
    + "messages TEXT,"
    + "unlock_condition TEXT,"
    + "location_list TEXT,"
    + "task_complete TEXT)",
    function(err) { if(err !== null) console.log(err); });

  db.run("CREATE TABLE location ("
    + "category STRING," /* TYPE: room, pset */
    + "id STRING,"
    + "name STRING,"
    + "unlock_condition TEXT,"
    + "monster_weights TEXT)",
    function(err) { if(err !== null) console.log(err); });

  db.run("CREATE TABLE monster_data ("
    + "id STRING,"
    + "name STRING,"
    + "hpRange TEXT,"
    + "meta TEXT," /* {adjustAtk: , adjustRep:} */
    + "atk TEXT,"
    + "rep TEXT,"
    + "messages TEXT,"
    + "unlock_condition TEXT,"
    + "task_complete TEXT,"
    + "special_events TEXT)",
    function(err) { if(err !== null) console.log(err); });

  db.run("CREATE TABLE skill ("
    + "id STRING,"
    + "name STRING,"
    + "unlock_condition TEXT,"
    + "messages TEXT,"
    + "exp_to_lv TEXT)", /* exp model */
    function(err) { if (err !== null) console.log(err); });

  db.run("CREATE TABLE item ("
    + "category STRING,"
    + "id STRING,"
    + "name STRING,"
    + "unlock_condition TEXT,"
    + "messages TEXT,"
    + "adjust_abilities TEXT,"
    + "special_events TEXT)",
    function(err) { if(err !== null) console.log(err); });

  db.run("CREATE TABLE info ("
    + "id STRING,"
    + "info TEXT)",
    function(err) { if(err !== null) console.log(err); });
});

module.exports = db;
