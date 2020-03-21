import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/main.dart';
import 'package:geo_beacon_flutter/styles.dart';
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ShareLocation extends StatefulWidget {
  final WebSocketChannel channel;

  ShareLocation({@required this.channel});
  @override
  _ShareLocationState createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation> {
  // Using onLocationChanged() method of `location` package
  // to get a stream of LocationData when the location changes.
  Stream<LocationData> locationStream;

  // Boolean to display widgets in UI.
  bool hasAccessToLoc;

  Timer timer;
  int clock;
  int hours;
  int minutes;
  int seconds;

  // Created a map object to store data and send the
  // same to the server. The server uses the same
  // structure of Map.
  Map locationDataMap = {
    'passkey': '',
    'using': true,
    'lat': 0.0,
    'lng': 0.0,
  };

  int dropdownValue = 60;

  @override
  void initState() {
    super.initState();
    hasAccessToLoc = false;
    hours = minutes = seconds = 0;
    clock = dropdownValue;
  }

  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
    locationStream = location.onLocationChanged();
    return _locationData;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (clock < 1) {
            timer.cancel();
            stopSharing();
          } else {
            clock = clock - 1;
            hours = clock ~/ 3600;
            minutes = (clock - hours * 3600) ~/ 60;
            seconds = (clock - minutes * 60 - hours*3600);
          }
        },
      ),
    );
  }

  // Method for MaterialButton
  Widget getButton({
    @required String message,
    @required VoidCallback function,
  }) {
    return Center(
      child: MaterialButton(
        padding: EdgeInsets.all(15.0),
        shape: StadiumBorder(),
        color: Theme.of(context).primaryColor,
        splashColor: Colors.white,
        child: Text(
          '$message',
          style: regularFontSize,
        ),
        onPressed: function,
      ),
    );
  }

  void stopSharing() {
    setState(() {
      locationDataMap['using'] = false;
    });
    widget.channel.sink.add(json.encode(locationDataMap));
    Timer(Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // If the location is not being streamed,
        // before starting to stream choose a passkey,
        !hasAccessToLoc
            ? getButton(
                message: locationDataMap['passkey'] == ''
                    // if passkey is not chosen, choose one.
                    ? 'Choose Passkey'
                    // Once Passkey is chosen, the app is ready to stream
                    // the location.
                    : 'Start sharing - ${locationDataMap['passkey']}',
                function: locationDataMap['passkey'] == ''
                    ? () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Hold On.."),
                                content: Text('Choose a passkey first.'),
                              );
                            });
                      }
                    : () {
                        // Location streaming has started and we are listening
                        // to the first tick of location stream that we get from
                        // getLocation() method. Once received the same is sent
                        // via websocket to the server.
                        startTimer();
                        getLocation().then((_locationData) {
                          setState(() {
                            hasAccessToLoc = true;
                            locationDataMap['lng'] = _locationData.longitude;
                            locationDataMap['lat'] = _locationData.latitude;
                            widget.channel.sink
                                .add(json.encode(locationDataMap));
                          });
                        });
                      })

            // Once location has started streaming, an option to
            // stop streaming is made available.
            : getButton(
                message: 'Stop Sharing Location',
                function: stopSharing,
              ),
        !hasAccessToLoc
            ? Center(
                child: DropdownButton(
                    value: dropdownValue,
                    icon: Icon(Icons.timer),
                    items: [
                      DropdownMenuItem(
                        child: Text('1 Min'),
                        value: 60,
                      ),
                      DropdownMenuItem(
                        child: Text('5 Min'),
                        value: 300,
                      ),
                      DropdownMenuItem(
                        child: Text('10 Min'),
                        value: 600,
                      ),
                      DropdownMenuItem(
                        child: Text('30 Min'),
                        value: 1800,
                      ),
                      DropdownMenuItem(
                        child: Text('1 Hr.'),
                        value: 3600,
                      ),
                      DropdownMenuItem(
                        child: Text('3 Hrs.'),
                        value: 3600 * 3,
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value;
                        clock = dropdownValue;
                      });
                    }),
              )
            : Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(child: Text('${hours}h : ${minutes}m : ${seconds}s remaining'),),
            ),
        // Before beginning the stream, check for all the available
        // passkeys and choose one to start sharing location.
        !hasAccessToLoc
            ? Expanded(
                child: StreamBuilder(
                  stream: widget.channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<String> passkeys = snapshot.data.split(",");
                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: passkeys.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 18.0,
                                left: 20.0,
                                right: 20.0,
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    boxShadow: boxShadows,
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      locationDataMap['passkey'] =
                                          passkeys[index];
                                    });
                                  },
                                  child: Center(
                                      child: Text(
                                          'Passkey ${index + 1} - ${passkeys[index]}',
                                          style: regularFontSize)),
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error : ${snapshot.error}'),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              )
            // After the initial tick from getLocation() listen to
            // the locationStream and keep sending the same to server
            // Also keeping track of the current location in the UI.

            : StreamBuilder(
                stream: locationStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    LocationData data = snapshot.data;
                    locationDataMap['lat'] = data.latitude ?? 0.0;
                    locationDataMap['lng'] = data.longitude ?? 0.0;
                    widget.channel.sink.add(json.encode(locationDataMap));
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 50.0),
                        child: Text(
                            snapshot.hasData
                                ? 'Current Loc : ${data.latitude}° ${data.longitude}°'
                                : '',
                            style: largeFontSize),
                      ),
                    );
                  } else {
                    return Text('');
                  }
                },
              ),
      ],
    );
  }

  @override
  void dispose() {
    // Before disposing the Widget, set the 'using' parameter
    // to false and notify the same to the server.
    locationDataMap['using'] = false;
    widget.channel.sink.add(json.encode(locationDataMap));
    widget.channel.sink.close();
    super.dispose();
  }
}
