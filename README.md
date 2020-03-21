# geo_beacon_flutter


## Qualifier Task


Language: Flutter
Must work in: Android, iOS (OK if you can just test in one, but we will test in both and if it doesn't work we'll send you the debug info so you can fix it).

Write a Flutter app that is able to share your location with anyone who has a specific passkey. For example, suppose you are going to start a hike with friends and you want them to know your location but only for the next 3 hours. You can do that in many ways, but let's say one is by letting people look up a passkey somewhere (to simplify things consider that it's OK to look up a list of passkeys in a static file hosted in github, so you don't need to setup a database).

Your app then will have two modes of operation: Someone is sharing their location (that means “carrying the beacon”) and everybody else can see that location (they are “following the beacon”).

## How To Run?
 - Go to `/server/` and run the server.
```
node server.js
```
 - Make sure your phone and the computer you are running the server on are connected to the same network.
 
 - Check for the IPv4 address of the computer running the server using either `ipconfig`(Windows) or `ifconfig`(Linux) and
   add the same in `/lib/config.dart` in the `websocketServerUrl` field.
   
 - Now you can run the app on your phone using - 
 ```
 flutter run
 ```
 ## Screenshots
 <img src="screenshots/1.jpg" height="650"> 
 
 Fig. 1 - Landing Page
 
 <img src="screenshots/2.jpg" height="650"> 
 
 Fig. 2 - Choose Passkey
 
 <img src="screenshots/3.jpg" height="650"> 
 
 Fig. 3 - Sharing Location
 
 <img src="screenshots/4.jpg" height="650"> 
 
 Fig. 4 - Tracking Location
