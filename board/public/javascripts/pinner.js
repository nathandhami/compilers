function init() {
    var mapCanvas = document.getElementById('map-canvas');
    var mapOptions = {
      	center: new google.maps.LatLng(49.277377, -122.914345),
        zoom: 10,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(mapCanvas, mapOptions);
    pinner();
}

function pinner() {
	$.each($(".eventAddress"), function(index, value) {
		pinAddress(value.innerText);
	});
}

function pinAddress(parsedAddress){
	geocoder = new google.maps.Geocoder();
	geocoder.geocode({ 'address': parsedAddress }, function(results, status) {
	  	if (status == google.maps.GeocoderStatus.OK) {
		    var marker = new google.maps.Marker({
		    map: map,
		    title: "Event Here",
		    position: results[0].geometry.location
		  	});
		}
	});
}


google.maps.event.addDomListener(window, 'load', init);
