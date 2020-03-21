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
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:50.0, left: 30.0),
            height: 100.0,
            width: double.infinity,
            child: Text('Geo Beacon',style: TextStyle(
              fontSize:21.0,
            ),),
            color: Color(0xFFB8E5F1),
          ),
          SizedBox(height: 50.0,),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
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
