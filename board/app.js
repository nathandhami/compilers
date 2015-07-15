// Module dependencies

var express = require("express");
var app = express();
var expressSession = require('express-session');
var nunjucks = require('nunjucks');
var users = require('./models/users.js');


app.use(express.urlencoded());
app.use(express.json());
app.use(app.router);

// Configuration

app.set('view engine', 'html');
app.use(express.static(__dirname + '/public'));
nunjucks.configure('views', {
  autoescape: true,
  express: app
});

// Routes

app.get('/', function (req, res) {
  res.render('index', {
    title: "Welcome"
  });
});

app.get('/login', function (req, res) {
  res.render('login.html', {
    title: "Login"
  });
});

app.get('/profile', function (req, res) {
  res.render('profile.html', {
    title: "Profile"
  });
});

app.get('/createevent', function (req, res) {
  res.render('createevent.html', {
    title: "Crate Event"
  });
});

app.listen(3000, function () {
  console.log("Express server listening on port 3000");
});