// Module dependencies

var express = require("express");
var app = express();
var expressSession = require('express-session');
var bodyParser = require('body-parser');
var nunjucks = require('nunjucks');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
// var users = require('./models/users.js');
require('./scripts/scripts.js');
require('./routes/login.js');

app.use(bodyParser.urlencoded({
  extended: true
}));

//passport stuff
app.use(passport.initialize());
app.use(passport.session());

app.use(express.urlencoded());
app.use(express.json());
app.use(app.router);

passport.use(new LocalStrategy({
  usernameField: 'loginusername',
  passwordField: 'loginpass'
}, function (username, password, done) {
  console.log(arguments);

  //ONCE REGISTRATION IS DONE, UNCOMMENT THIS BIT
  //THIS BIT IS FOR CHECKING FOR MONGO USER

  // models.users.findOne({
  //   username: username
  // }, function (err, user) {
  //   if (err) {
  //     return done(err);
  //   }
  //   if (!user) {
  //     return done(null, false, {
  //       message: 'Incorrect username or password.'
  //     });
  //   }
  //   if (user.password !== password) {
  //     return done(null, false, {
  //       message: 'Incorrect username or password.'
  //     });
  //   }
  //   return done(null, user);
  // });


  //AND THE REST OF THIS BIT IS THE HARDCODED
  //BIT FOR TESTING OF PASSPORT SO DELETE IT AFTER

  var usernametest = "test";
  var passwordtest = "test";
  if (username === usernametest && password === passwordtest) {
    done(null, {
      username: username
    });
  }
}));

passport.serializeUser(function (user, done) {
  done(null, user.username);
});

passport.deserializeUser(function (id, done) {
  done(null, {
    username: 'test'
  });
});

//end passport stuff

// Configuration

app.set('view engine', 'html');
app.use(express.static(__dirname + '/public'));
nunjucks.configure('views', {
  autoescape: true,
  express: app
});

// Routes

//home page
app.get('/', function (req, res) {
  res.render('index', {
    title: "Welcome"
  });
});

//login and registration page
app.get('/login', function (req, res) {
  res.render('login.html', {
    title: "Login"
  });
});

//post to login
app.post('/login',
  passport.authenticate('local', {
    successRedirect: '/profile',
    failureRedirect: '/'
  })
);

//logout and redirect to home
app.get('/logout', function (req, res) {
  req.logout();
  res.redirect('/');
});

//profile page
app.get('/profile', function (req, res) {
  res.render('profile.html', {
    title: "Profile"
  });
});

//make a new event
app.get('/createevent', function (req, res) {
  res.render('createevent.html', {
    title: "Crate Event"
  });
});

app.listen(3000, function () {
  console.log("Express server listening on port 3000");
});