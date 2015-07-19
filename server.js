
require('coffee-script');
var express = require('express');
var app = express();

//set up static folder
app.use(express.static('public'));
//set up asset pipelines
app.use(require("connect-assets")());
//set up views
app.engine('jade', require('jade').__express);
app.set('view engine', 'jade');
app.set('views', __dirname + '/views');

app.get('/', function(req, res) {
  res.render('index', { title: 'Hey', message: 'Hello there!'});
});

//handle data
var YAML = require('yamljs');

app.get('/problemsets', function(req, res) {
  obj = YAML.load('data/problemsets.yaml');
  res.json(obj);
});

var server = app.listen(3000, function() {
  var host = server.address().address;
  var port = server.address().port;
  console.log('Example app listening at http://%s:%s', host, port);
});
