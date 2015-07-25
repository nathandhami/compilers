var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var geocoder = require('geocoder');

var eventSchema = new Schema({
	//event name
	name:{
		type: String,
    	required: true
    	},
    //name of creator	
    username:{
    	type: String,
    	required: true
    	},
    date:{
	// to do: Should definetly try to get this submitted as a "date-time" field or something, if possible. The date's are currently stored in two different formats, which would make searches on dates impossible
    	type: String,
    	required: true
    	},
	//location name
    location:{
    	type: String,
    	required: true
    	},
    //to do: use maps API to convert location name into lat-long coordinates	
    latitude:{
    	type: String
    },	
    longitude:{
    	type: String
    },
    description:{
    	type: String,
    	required: true
    }
});	


var Event = mongoose.model('Event', eventSchema);

module.exports = Event;			
