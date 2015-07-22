// var mongoose = require('mongoose');

// var db = mongoose.connection;

// db.on('error', console.error);
// db.once('open', function () {
//   console.log("CONNECTION MADE TO CUSTOMERS");

//   // Create our schema and model here
//   var UserSchema = new mongoose.Schema({
//     "username": String,
//     "password": String,
//     "email": String
//   });
// });


// mongoose.connect('mongodb://board:secur1ty@ds047632.mongolab.com:47632/board');

// module.exports = mongoose.model('User', UserSchema);

var mongoose = require('mongoose');
var Schema = mongoose.Schema;

// create a schema
var userSchema = new Schema({
  username: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true
  },
  password: {
    type: String,
    required: true
  }
});

//before we save a new user, we want to hash the password
userSchema.pre('save', function (next) {

  //todo

  next();
});

// create a model using the above schema
var User = mongoose.model('User', userSchema);

// make this available to our users in our Node applications
module.exports = User;