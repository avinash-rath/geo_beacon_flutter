import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_beacon_flutter/broadcastListener.dart';
import 'package:geo_beacon_flutter/config.dart';
import 'package:geo_beacon_flutter/styles.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Listens for the list of passkeys with active location sharing.
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
          if (snapshot.data.length == 0) {
            return Center(
              child: Text(
                'No one is sharing location.',
                style: regularFontSize,
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                    itemCount: passkeys.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topRight: Radius.circular(20.0)),
                            color: Colors.white,
                          ),
                          height: 50.0,
                          child: Center(child: Text('Active - ${passkeys[index]}',
                          style: regularFontSize,),),
                        ),
                        onTap: () {
                          // Start listening to the broadcast for that passkey.
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => BroadcastListener(
                                passkey: passkeys[index],
                                channel: IOWebSocketChannel.connect(
                                    '$websocketServerUrl:$broadcastListenerPort'),
                              ),
                            ));
                        },
                      );
                    }),
              ),
            );
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
