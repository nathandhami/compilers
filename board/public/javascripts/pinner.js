function init() {
    var mapCanvas = document.getElementById('map-canvas');
    var mapOptions = {
      	center: new google.maps.LatLng(49.277377, -122.914345),
        zoom: 10,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(mapCanvas, mapOptions);
}


google.maps.event.addDomListener(window, 'load', init);