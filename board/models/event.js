var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var eventSchema = new Schema({
	//event name
	name:{
		type: String,
    	required: true
    	},
    //name of creator	
    username:{
    	type: String,
    	//required: true
    	},
    date:{
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