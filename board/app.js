// Module dependencies
var express = require("express"),
  app = express(),
  expressSession = require('express-session'),
  bodyParser = require('body-parser'),
  mongoose = require('mongoose'),
  nunjucks = require('nunjucks'),
  passport = require('passport'),
  LocalStrategy = require('passport-local').Strategy;
require('./scripts/scripts.js');

//middleware
app.use(bodyParser.urlencoded({
  extended: true
}));

//connect to mongoDB
mongoose.connect('mongodb://board:secur1ty@ds047632.mongolab.com:47632/board');

//grab all the models
var User = require('./models/users');


//Passport is used to handle sessions

app.use(passport.initialize());
app.use(passport.session());

app.use(express.urlencoded());
app.use(express.json());
app.use(app.router);

passport.use(new LocalStrategy({
  usernameField: 'loginusername',
  passwordField: 'loginpass'
}, function (username, password, done) {
  User.findOne({
    username: username
  }, function (err, user) {
    if (err) {
      return done(err);
    }
    if (!user) {
      return done(null, false, {
        message: 'Incorrect username or password.'
      });
    }
    if (user.password !== password) {
      return done(null, false, {
        message: 'Incorrect username or password.'
      });
    }
    return done(null, user);
  });
}));


//store session
passport.serializeUser(function (user, done) {
  done(null, user.username);
});

//delete session on logout
passport.deserializeUser(function (id, done) {
  User.findById(id, function (err, user) {
    done(err, user);
  });
});

//end Passport stuff


//App configuration stuff

app.set('view engine', 'html');
app.use(express.static(__dirname + '/public'));
nunjucks.configure('views', {
  autoescape: true,
  express: app
});

//For now, check if user is authenticated on EVERY route.
//It will make life easier during development
//later on we can change this to only check on profile/create event/buddy pages
app.all('*', function (req, res, next) {
  console.log(req.isAuthenticated());
  if (req.isAuthenticated && req.isAuthenticated() === true) {
    res.locals.user = req.user.username;
    res.locals.user_id = req.user._id;
  } else {
    res.locals.user = null;
    res.locals.user_id = null;
  }
  next();
});

// End App configuration

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
//TODO - proper callbacks
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
      //if it didn't save, read your console to find out why
      //probably because you didn't pick a unique username
      //TODO - handle this properly (ie alert user instead of trying to post it)
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