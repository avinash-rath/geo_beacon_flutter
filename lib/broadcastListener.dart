import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/main.dart';
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                      child: Text('Track another location'),
                      onPressed: () {
                        Timer(Duration(milliseconds: 500), () {
                          Navigator.of(context).pop();
                        });
                      }),
                  Text('lat:$lat\nlng:$lng'),
                ],
              ),
            ),
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
