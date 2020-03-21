import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/activeLocListener.dart';
import 'package:geo_beacon_flutter/broadcastListener.dart';
import 'package:geo_beacon_flutter/config.dart';
import 'package:geo_beacon_flutter/shareLocation.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Beacon',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: ShareLocation(
              channel: IOWebSocketChannel.connect(
                '$websocketServerUrl:$locationSendPort',
              ),
            ),
          ),
          Expanded(child:  ActiveLocListener(
        channel: IOWebSocketChannel.connect(
            '$websocketServerUrl:$activeLocListenerPort'),
      ),)
        ],
      ),
    );
  }
}
