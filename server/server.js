var WebSocketServer = require('websocket').server;
var http = require('http');
var https = require('https');

//__________________________________________________
// Reading passkeys from file stored on GitHub @
// github.com/avinash-rath/geo_beacon_flutter
// path to file -> /passkeys.txt/
var passkeysMapList = [];
var passkeysList = [];
function mapPasskeys(item,count) {
  passkeysMapList.push({
    'passkey':item,
    'using':false,
    'lat':0.0,
    'lng':0.0
  });
}
//__________________________________________________

// using GitHub API to read the static file stored in the repo
var options = {
  'hostname': 'api.github.com',
  'path':'/repos/avinash-rath/geo_beacon_flutter/contents/passkeys.txt',
  'method':'GET',
  'headers':{'User-Agent':'avinash-rath'}

}

https.get(options,
(resp)=>{
  var passkeys = '';
  resp.on('data', (data)=>{
    passkeys += data;
  });
  resp.on('end', () =>{
    passkeys = JSON.parse(passkeys);
    var buff = new Buffer.from(passkeys['content'],'base64');
    passkeys = buff.toString('ascii');
    passkeys = passkeys.split('\n');
    passkeys.splice(-1,1);
    passkeys.forEach(mapPasskeys);
  });
}).on('error',(err)=> {
  console.log("Error : "+err.message);
});

//__________________________________________________

// Creating http server for the Websocket server.
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


// WebSocket server
wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin '
      + request.origin + '.');
  var connection = request.accept(null, request.origin);
  console.log((new Date()) + ' Connection accepted. - Locations sharing server');
  passkeysList = [];
  //Removing those passkeys which are currently in use
  passkeysMapList.forEach((item,index)=>{
    if(item['using']!=true){
      passkeysList.push(item['passkey']);
    }
  });
  if(passkeysList.length == 0) {
    connection.sendUTF('No free keys available at this moment');
  } else {
    connection.sendUTF(passkeysList);
  }
  
  // Handle messages
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
      // Receiving JSON object of same structure of elements
      // in passkeysMap.
      locationData = JSON.parse(message.utf8Data);
      for(var i = 0; i<passkeysMapList.length; i++) {
        if(passkeysMapList[i]['passkey'] === locationData['passkey']) {
          passkeysMapList[i] = locationData;
          break;
        }
      }
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    console.log('Connection closed');
  });
});
//__________________________________________________

// Create one server to constantly update which passkeys
// are being used to share location.
var activeLocServer = http.createServer(function(request, response) {
});

activeLocServer.listen(1339, function () {
  console.log((new Date())+" ActiveLoc server running on port : 1339");
})

activeLocWsServer = new WebSocketServer({
  httpServer:activeLocServer
});

activeLocWsServer.on('request', function(request) {
  var connection = request.accept(null,request.origin);
  console.log('Connection accepted - ActiveLoc Server')
  setInterval(()=>{
    passkeysList = []
    passkeysMapList.forEach((item,index) => {
      if(item['using']==true){
        passkeysList.push(item['passkey']);
      }
    });
    connection.sendUTF(passkeysList);
  },1000);
  connection.on('close', function(connection){
    console.log('Connection closed - ActiveLocServer')
  })
});
//__________________________________________________

// Create broadcast server to broadcast the geo 
// location to all the connected users for eaach passkey
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
  console.log((new Date()) + ' Connection accepted. - broadcasting server');
  

  // Handle messages
  connection.on('message', function(message) {
    if (message.type === 'utf8') {
     // get passkey from user and send relative 
     // location data to the client.
     var passkey = message.utf8Data;
     var index = 0;
     for(var i = 0 ; i < passkeysMapList.length ; i++) {
      if(passkey === passkeysMapList[i]['passkey']) {
        index = i;
        break;
      }
     }
     // sending updates on location every 1 sec.
     setInterval(()=>{
      connection.sendUTF(
        JSON.stringify({
          'lat':passkeysMapList[index]['lat'],
          'lng':passkeysMapList[index]['lng']
        })
      ); 
     },1000)
    }
  });

  connection.on('close', function(connection) {
    // close user connection
    console.log('Connection closed - Broadcast server');
  });
});
//__________________________________________________
