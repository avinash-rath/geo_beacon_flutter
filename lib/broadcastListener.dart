import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/styles.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BroadcastListener extends StatefulWidget {
  final WebSocketChannel channel;
  final String passkey;

  BroadcastListener({
    @required this.channel,
    @required this.passkey,
  });

  @override
  _BroadcastListenerState createState() => _BroadcastListenerState();
}

class _BroadcastListenerState extends State<BroadcastListener> {
  @override
  void initState() {
    super.initState();
    widget.channel.sink.add(widget.passkey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.channel.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var collection = json.decode(snapshot.data);
            var lat = collection['lat'];
            var lng = collection['lng'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 50.0, left: 30.0),
                  height: 100.0,
                  width: double.infinity,
                  child:
                      Text('Tracking - ${widget.passkey}', style: headerStyle),
                  color: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: Container(),
                ),
                MaterialButton(
                  padding: EdgeInsets.all(20.0),
                  shape: StadiumBorder(),
                    child: Text(
                      'Track another location',
                      style: largeFontSize,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Timer(Duration(milliseconds: 500), () {
                        Navigator.of(context).pop();
                      });
                    }),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Latitude',
                        style: largeFontSize,
                      ),
                      Text(
                        '$lat°',
                        style: largeFontSize,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Longitude',
                        style: largeFontSize,
                      ),
                      Text(
                        '$lng°',
                        style: largeFontSize,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
