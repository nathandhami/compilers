var mongoose = require('mongoose');

var db = mongoose.connection;

db.on('error', console.error);
db.once('open', function () {
  console.log("CONNECTION MADE TO CUSTOMERS");

  // Create our schema and model here
  var UserSchema = new mongoose.Schema({
    "username": String,
    "password": String,
    "email": String
  });
  var User = mongoose.model('User', userSchema);

  //manually create a user while testing
  //after we figure this out, users will be created from /login.html
  var coolguy = new User({
    username: 'coolguy123',
    password: 'coolguy123',
    email: 'coolguy123@gmail.com'
  });

  coolguy.save(function (err, coolguy) {
    if (err) return console.error(err);
    console.dir(coolguy);
  });
});


mongoose.connect('mongodb://board:secur1ty@ds047632.mongolab.com:47632/board');

module.exports = mongoose.model('User', UserSchema);