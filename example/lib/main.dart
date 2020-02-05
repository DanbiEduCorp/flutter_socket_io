import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(MyApp());

const String URI = "https://msg.danbi.biz/users";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> toPrint = ["trying to conenct"];
  SocketIOManager manager;
  SocketIO socket;
  bool isProbablyConnected = false;

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket();
  }

  initSocket() async {
    setState(() => isProbablyConnected = true);
    SocketOptions options = SocketOptions(
      //Socket IO server URI
        URI,
        //Query params - can be used for authentication
//        query: {
//          "auth": "--SOME AUTH STRING---",
//          "info": "new connection from adhara-socketio",
//          "timestamp": DateTime.now().toString()
//        },
        //Enable or disable platform channel logging
        enableLogging: true,
        transports: [Transports.WEB_SOCKET] //Enable required transport
    );
    options.timeout = 2000;
    socket = await manager.createInstance(options);

    socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
      sendMessage();
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("news", (data) {
      pprint("news");
      pprint(data);
    });
    socket.on('message', (dynamic data) {
      pprint('=============>onMessage::' + data);
    });
    socket.on('info', (dynamic data) {
      pprint('=============>recv info::' + data);
    });
    socket.connect();
    pprint("connecting...");
  }

  disconnect() async {
    await manager.clearInstance(socket);
    setState(() => isProbablyConnected = false);
  }

  sendMessage() async {
    if (socket != null) {
      pprint("sending message...");
      socket.emit('login', {'authToken': '*danbi*', 'actorId': 111});
      pprint("Message emitted...STEP01");
      socket.emit('usePlugin', {'id': 'rtc'});
//      socket.emit("message", [
//        "Hello world!",
//        1908,
//        {
//          "wonder": "Woman",
//          "comics": ["DC", "Marvel"]
//        },
//        {
//          "test": "=!./"
//        },
//        [
//          "I'm glad",
//          2019,
//          {
//            "come back": "Tony",
//            "adhara means": ["base", "foundation"]
//          },
//          {
//            "test": "=!./"
//          },
//        ]
//      ]);
      pprint("Message emitted...STEP02-1");

      await socket.emit('message', {
        'type': 'answer', 'to': 8402, 'from': 111, 'test': 'test'
      });
      pprint("Message emitted...STEP03");
    }
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: TextTheme(
            title: TextStyle(color: Colors.white),
            headline: TextStyle(color: Colors.white),
            subtitle: TextStyle(color: Colors.white),
            subhead: TextStyle(color: Colors.white),
            body1: TextStyle(color: Colors.white),
            body2: TextStyle(color: Colors.white),
            button: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.white),
            overline: TextStyle(color: Colors.white),
            display1: TextStyle(color: Colors.white),
            display2: TextStyle(color: Colors.white),
            display3: TextStyle(color: Colors.white),
            display4: TextStyle(color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
              buttonColor: Colors.lightBlue,
              splashColor: Colors.cyan
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Adhara Socket.IO example'),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Center(
                    child: ListView(
                      children: toPrint.map((String _) => Text(_ ?? "")).toList(),
                    ),
                  )),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      child: Text("Connect"),
                      onPressed: isProbablyConnected?null:initSocket,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: RaisedButton(
                        child: Text("Send Message"),
                        onPressed: isProbablyConnected?sendMessage:null,
                      )
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: RaisedButton(
                        child: Text("Disconnect"),
                        onPressed: isProbablyConnected?disconnect:null,
                      )
                  ),
                ],
              ),
              SizedBox(height: 12.0,)
            ],
          ),
        ),
      ),
    );
  }
}
