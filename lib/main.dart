import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/activeLocListener.dart';
import 'package:geo_beacon_flutter/config.dart';
import 'package:geo_beacon_flutter/shareLocation.dart';
import 'package:geo_beacon_flutter/styles.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Beacon',
      theme: ThemeData(
        primaryColor: Color(0xFF87CEEB),
        fontFamily: 'Quicksand'
      ),
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
            padding: EdgeInsets.only(top: 50.0, left: 30.0),
            height: 100.0,
            width: double.infinity,
            child: Text(
              'Geo Beacon',
              style: headerStyle
            ),
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 25.0,
          ),
          Expanded(
            child: ShareLocation(
              channel: IOWebSocketChannel.connect(
                '$websocketServerUrl:$locationSendPort',
              ),
            ),
          ),
          Divider(
            thickness: 2.0,
          ),
          Container(
            child: Center(
              child: Text(
                'Active Locations Listener.',
                style: headerStyle,
              ),
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadows,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                color: Theme.of(context).primaryColor,
              ),
              child: ActiveLocListener(
                channel: IOWebSocketChannel.connect(
                    '$websocketServerUrl:$activeLocListenerPort'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
