import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

Map put;
var uuid = Uuid();
var id;

class MyApp extends StatefulWidget {
  @override
  CommandAppState createState() => CommandAppState();
}

class CommandAppState extends State<MyApp> {
  String cmd;
  String output;
  var getoutput = "";
  var getstatuscode;
  var getid;

  var fsconnect = FirebaseFirestore.instance;

  myget() async {
    var d =
        await fsconnect.collection("command1").where("id", isEqualTo: id).get();
    print(id);
    print(d.docs[0].data());
    print(d.docs[0].get('status'));
    //getid = d.docs[0].get('id');
    getoutput = d.docs[0].get('output');
    getstatuscode = d.docs[0].get('status');
    setState(() {});
  }

  command(cmd) async {
    print(cmd);
    var url = "http://192.168.43.133/cgi-bin/cmd.py?cmd=${cmd}";
    var res = await http.get(url);
    id = uuid.v1(); // Generate a v1 (time-based) id
    print(id);
    print(res.body);
    fsconnect.collection("command1").add({
      'id': id,
      'output': res.body,
      'status': res.statusCode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Linux Terminal'),
      ),
      backgroundColor: Colors.grey.shade300,
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            // Container(
            height: WidgetsBinding.instance.window.physicalSize.height / 5,
            width: WidgetsBinding.instance.window.physicalSize.width,
            color: Colors.black,
            //  child: Column(
            child: ListView(
              children: <Widget>[
                Text(
                  "[ shell ]#\n" + "$getoutput",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            // ),
          ),
          //),
          Center(
            child: Container(
              width: WidgetsBinding.instance.window.physicalSize.width,
              height: 250,
              color: Colors.grey.shade300,
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      cmd = value;
                    },
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter linux command",
                      prefixIcon: Icon(Icons.tablet_android),
                      hoverColor: Colors.blueAccent,
                    ),
                  ),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    child: Text("Run"),
                    onPressed: () {
                      command(cmd);
                      print("send ..");
                      print(cmd);
                    },
                  ),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    child: Text('Output'),
                    onPressed: () {
                      myget();
                      print("get data ...");
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
