// Module dependencies

var express = require("express");
var app = express();
var expressSession = require('express-session');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var nunjucks = require('nunjucks');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
require('./scripts/scripts.js');

//connect to mongoDB
mongoose.connect('mongodb://board:secur1ty@ds047632.mongolab.com:47632/board');

//require mongoose schema for User
var User = require('./models/users');

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
  console.log(arguments);
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

app.all('*', function (req, res, next) {
  console.log(req.isAuthenticated());
  if (req.isAuthenticated && req.isAuthenticated() === true) {
    res.locals.user = req.user.username;
    //mongo id bits
    //res.locals.user_id = req.user._id;
  } else {
    res.locals.user = null;
    //res.locals.user_id = null;
  }
  next();
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

//post to register a user
app.post('/register', function (req, res) {

  //create newUser object
  var newUser = new User({
    username: req.body.registerusername,
    email: req.body.registeremail,
    password: req.body.registerpassword
  });

  //and attempt to save it
  newUser.save(function (err) {
    if (!err) {
      console.log('You just created a new user.');
      res.render('login.html', {
        title: "Login"
      });
    } else {
      console.log(err);
      res.render('login.html', {
        title: "Login"
      });
    }
  });
});

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