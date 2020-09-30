import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer;
  Color col, col2;
  String advice;
  bool loading = true,  connected = true;

  checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) { 
        getAdvice();
      }
    } on SocketException catch (_) {
      setState(() {
        connected = false;
      });
    }
  }

  getAdvice() async {
    setState(() {
      loading = true;
    });
    var response = await http.get('https://api.adviceslip.com/advice');
    var  adviceBody = json.decode(response.body);
    setState(() {
      advice = adviceBody['slip']['advice'];
      loading = false;
      connected = true;
    }); 
    print(advice);
  }

  getColor() {
    timer = Timer.periodic(Duration(seconds: 5), (t) {
      setState(() {
        col = Color.fromRGBO(Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1.0);        
        col2 = Color.fromRGBO(Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1.0);        
      });
    });
  }

  @override
  void initState() {
    getColor();
    checkConnection();
    super.initState();
  }
  
  @override
  dispose() {
    timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown, 
    ]);

    if (!connected) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.signal_cellular_connected_no_internet_4_bar,
                size: 50,
                color: Colors.white,
              ),
              Text(
                'Check your internet connection.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18
                )
              ),
              Padding(padding: EdgeInsets.all(10),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlineButton.icon(
                    onPressed: checkConnection,
                    icon: Icon(Icons.replay, color: Colors.white),
                    borderSide: BorderSide(color: Colors.white),
                    label: Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                  ),
                  OutlineButton.icon(
                    onPressed: checkConnection,
                    icon: Icon(Icons.clear, color: Colors.white),
                    borderSide: BorderSide(color: Colors.white),
                    label: Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.white,
                      )
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedContainer(
          // margin: EdgeInsets.all(1),
          width: double.infinity,
          duration: Duration(seconds: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // stops: [0.3, 1],
              colors: [col, col2]
            )
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => exit(0),
                          icon: Icon(Icons.clear, color: Colors.white,),
                          iconSize: 30,
                        )
                      ],
                    ),
                    Image.asset('assets/monk.webp', height: 200, width: 200,),
                    Padding(padding: EdgeInsets.all(10)),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: advice == null ?
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text(
                          advice,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),              
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        padding: EdgeInsets.all(15),
                        onPressed: getAdvice,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60)
                        ),
                        child: loading ? 
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : 
                          Icon(Icons.replay, color: Colors.white, size: 40),
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      MaterialButton(
                        elevation: 0,
                        padding: EdgeInsets.all(15),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: advice));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60)
                        ),
                        child: Icon(Icons.content_copy, color: Colors.white, size: 40),
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      MaterialButton(
                        elevation: 0,
                        padding: EdgeInsets.all(15),
                        onPressed: () {
                          Share.share(advice + ' 😇');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60)
                        ),
                        child: Icon(Icons.share, color: Colors.white, size: 40),
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}