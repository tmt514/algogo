
require('coffee-script');
require('coffee-script/register');
var express = require('express');
var app = express();
var session = require('express-session');
var flash = require('connect-flash');
var uuid = require('node-uuid');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var multer = require('multer');

//set up static folder
app.use(express.static('public'));
app.use('/scripts', express.static(__dirname + '/node_modules'));
//set up asset pipelines
app.use(require("connect-assets")());
//set up views
app.engine('jade', require('jade').__express);
app.set('view engine', 'jade');
app.set('views', __dirname + '/views');
//set up middleware
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.use(bodyParser.json()); // for parsing application/json
//app.use(multer()); // for parsing multipart/form-data
//set up sessions
app.use(cookieParser());
app.use(session({
    genid: function(req) {
          return uuid.v4(); //use UUID
    },
    secret: 'tmt-test',
    cookie: { maxAge: 8640000 }
}));
app.use(flash());
// Expose the flash function to the view layer
app.use(function(req, res, next) {
  res.locals.flash = req.flash.bind(req)
  next()
});
//handle data
var YAML = require('yamljs');

app.get('/problemsets', function(req, res) {
  obj = YAML.load('data/problemsets.yaml');
  res.json(obj);
});

var fs = require('fs');

//read all controllers
app.use('/', require('./controllers/index'));

// HTTPS server
var https = require('https');

var options = {
  key: fs.readFileSync('certs/server.key'),
  cert: fs.readFileSync('certs/server.crt')
};

var server = https.createServer(options, app).listen(3000, function() {
  var host = server.address().address;
  var port = server.address().port;
  console.log('Example app listening at http://%s:%s', host, port);
});

