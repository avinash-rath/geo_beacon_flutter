var WebSocketServer = require('websocket').server;
var http = require('http');

//__________________________________________________

//__________________________________________________
var server = http.createServer(function(request, response) {
});
server.listen(1337, function() {
    console.log((new Date()) + " Server is listening on port : 1337");
 });
//__________________________________________________
// create the server
wsServer = new WebSocketServer({
  httpServer: server
});

var location='';

// WebSocket server
wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin '
      + request.origin + '.');
  var connection = request.accept(null, request.origin);
  console.log((new Date()) + ' Connection accepted.');
  connection.sendUTF('Message from server : Hello from the other side!')

  // Handle messages
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
      // process WebSocket message
      location = message.utf8Data
      connection.sendUTF('Message from server '+message.utf8Data);
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    console.log('Connection closed');
  });
});
//__________________________________________________
var broadcastServer = http.createServer(function(request, response) {
});

broadcastServer.listen(1338, function () {
  console.log((new Date())+" Broadcast server running on port : 1338");
})

broadcastWsServer = new WebSocketServer({
  httpServer:broadcastServer
});

broadcastWsServer.on('request', function(request) {
  console.log((new Date()) + ' Connection from origin '
    + request.origin + '.');
  var connection = request.accept(null, request.origin);
  console.log((new Date()) + ' Connection accepted.');
  connection.sendUTF('Broadcasting location : '+location);

  setInterval(function () {
    connection.sendUTF('Broadcasting location : '+location);
  },1000)

  // Handle messages
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
     // process WebSocket message
     connection.sendUTF(message.utf8Data);
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    console.log('Connection closed');
  });
});
//__________________________________________________
