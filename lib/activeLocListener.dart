import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/broadcastListener.dart';
import 'package:geo_beacon_flutter/config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ActiveLocListener extends StatefulWidget {
  final WebSocketChannel channel;
  ActiveLocListener({@required this.channel});
  @override
  _ActiveLocListenerState createState() => _ActiveLocListenerState();
}

class _ActiveLocListenerState extends State<ActiveLocListener> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.channel.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<String> passkeys = snapshot.data.split(",");
          if (passkeys.length == 0)
            return Text('No one is sharing location');
          else {
            return ListView.builder(
                itemCount: passkeys.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                      height: 30.0,
                      child: Text(passkeys[index]),
                    ),
                    onTap: () {
                      setState(() {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => BroadcastListener(
                            passkey:passkeys[index],
                            channel: IOWebSocketChannel.connect(
                                '$websocketServerUrl:$broadcastListenerPort'),
                          ),
                        ));
                      });
                    },
                  );
                });
          }
        } else if (snapshot.hasError) {
          return Text('Error : ${snapshot.error}');
        } else {
          return Container();
        }
      },
    );
  }
}
