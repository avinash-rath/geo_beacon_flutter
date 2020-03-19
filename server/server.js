var WebSocketServer = require('websocket').server;
var http = require('http');

var server = http.createServer(function(request, response) {
});
server.listen(1337, function() {
    console.log((new Date()) + " Server is listening on port : 1337");
 });

// create the server
wsServer = new WebSocketServer({
  httpServer: server
});

// WebSocket server
wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin '
      + request.origin + '.');
  var connection = request.accept(null, request.origin);
  console.log((new Date()) + ' Connection accepted.');
  connection.sendUTF('Hello from the other side!')

  // This is the most important callback for us, we'll handle
  // all messages from users here.
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
      // process WebSocket message
      connection.sendUTF(message);
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    console.log('Connection closed');
  });
});