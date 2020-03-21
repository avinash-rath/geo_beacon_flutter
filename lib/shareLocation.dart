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
  Stream<LocationData> locationStream;

  // Boolean to display widgets in UI.
  bool hasAccessToLoc;

  // Created a map object to store data and send the
  // same to the server. The server uses the same
  // structure of Map.
  Map locationDataMap = {
    'passkey': '',
    'using': true,
    'lat': 0.0,
    'lng': 0.0,
  };

  @override
  void initState() {
    super.initState();
    hasAccessToLoc = false;
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

  getButton() {
    return Center(
      child: MaterialButton(
        color: Colors.lightBlue[100],
        splashColor: Colors.white,
        child: locationDataMap['passkey'] == ''
            ? Text(
                'Choose passkey',
                style: regularFontSize,
              )
            : Text(
                'Start sharing - ${locationDataMap['passkey']}',
                style: regularFontSize,
              ),
        onPressed: locationDataMap['passkey'] == ''
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
                getLocation().then((_locationData) {
                  setState(() {
                    hasAccessToLoc = true;
                    locationDataMap['lng'] = _locationData.longitude;
                    locationDataMap['lat'] = _locationData.latitude;
                    widget.channel.sink.add(json.encode(locationDataMap));
                  });
                });
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        !hasAccessToLoc ? getButton() : Container(),
        hasAccessToLoc
            ? Center(
                child: MaterialButton(
                  child: Text('Stop sharing location', style: regularFontSize),
                  color: Colors.lightBlue[100],
                  onPressed: () {
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
                  },
                ),
              )
            : Container(),
        !hasAccessToLoc
            ? SizedBox(
                height: (MediaQuery.of(context).size.height / 4),
                child: StreamBuilder(
                  stream: widget.channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<String> passkeys = snapshot.data.split(",");
                      return ListView.builder(
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
                    } else {
                      return Container();
                    }
                  },
                ),
              )
            : Container(),
        hasAccessToLoc
            ? StreamBuilder(
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
                                ? 'Current Loc : ${data.latitude} ${data.longitude}'
                                : '',
                            style: largeFontSize),
                      ),
                    );
                  } else {
                    return Text('');
                  }
                },
              )
            : Container(),
      ],
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
