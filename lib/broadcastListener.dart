import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BroadcastListener extends StatefulWidget {
  final WebSocketChannel channel;

  BroadcastListener({@required this.channel});

  @override
  _BroadcastListenerState createState() => _BroadcastListenerState();
}

class _BroadcastListenerState extends State<BroadcastListener> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.channel.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Text(snapshot.hasData ? '${snapshot.data}' : '');
        },
      );
  }
}
