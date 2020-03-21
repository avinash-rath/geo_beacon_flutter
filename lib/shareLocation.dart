import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/main.dart';
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
  bool hasAccessToLoc;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MaterialButton(
              color: Colors.lightBlue[100],
              splashColor: Colors.white,
              child: locationDataMap['passkey'] == ''
                  ? Text('Choose passkey')
                  : Text('Start sharing - ${locationDataMap['passkey']}'),
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
            hasAccessToLoc
                ? MaterialButton(
                    child: Text('Stop sharing location'),
                    onPressed: () {
                      setState(() {
                        locationDataMap['using']=false;
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
                  )
                : Container(),
            !hasAccessToLoc
                ? SizedBox(
                    height: 150.0,
                    child: StreamBuilder(
                      stream: widget.channel.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          print(snapshot.data);
                          List<String> passkeys = snapshot.data.split(",");
                          return ListView.builder(
                              itemCount: passkeys.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  child: Container(
                                    height: 30,
                                    child: Center(
                                        child: Text('${passkeys[index]}')),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      locationDataMap['passkey'] =
                                          passkeys[index];
                                    });
                                  },
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
                        return Text(snapshot.hasData
                            ? 'Current Loc : ${data.latitude} ${data.longitude}'
                            : '');
                      } else {
                        return Text('');
                      }
                    },
                  )
                : Container(),
            SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
