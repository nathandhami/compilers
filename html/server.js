var http = require("http");
var url = require("url");

function start(route, handle) {
	function onRequest(request, response) {
		var pathname = url.parse(request.url).pathname;
		var query = url.parse(request.url).query;
		console.log("Request for " + pathname + " received.");

	route(handle, pathname, response, request);
	}

	http.createServer(onRequest).listen(8080);
}
exports.start = start;

