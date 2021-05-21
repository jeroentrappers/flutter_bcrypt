import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _hash = 'Unknown';

  @override
  void initState() {
    super.initState();
    hash();
  }

  Future<void> hash() async {
    String hash;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      hash = await FlutterBcrypt.hashPw(
          password: r'3282aae5-f104-4639-88a3-3af9a1efb069',
          salt: r'$2b$06$C6UzMDM.H6dfI/f/IKxGhu');

      var salt = await FlutterBcrypt.salt();
      print("salt " + salt);

      var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);
      print("salt10 " + salt10);

      var pwh = await FlutterBcrypt.hashPw(
          password: r'ThisIsSuperSecret', salt: salt);

      print("pwh " + pwh);

      var pwh10 = await FlutterBcrypt.hashPw(
          password: r'ThisIsSuperSecret', salt: salt10);
      print("pwh10 " + pwh10);

      var result =
          await FlutterBcrypt.verify(password: r'ThisIsSuperSecret', hash: pwh);
      print("result: " + (result ? "ok" : "nok"));

      var result10 = await FlutterBcrypt.verify(
          password: r'ThisIsSuperSecret', hash: pwh10);
      print("result10: " + (result10 ? "ok" : "nok"));

      var resultFailed = await FlutterBcrypt.verify(
          password: r'ThisPasswordIsWrong', hash: pwh10);
      print("resultFailed: " + (resultFailed ? "nok" : "ok"));
    } on PlatformException {
      hash = 'Failed to get hash.';
    }

    if (!mounted) return;

    setState(() {
      _hash = hash;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bcrypt plugin example app'),
        ),
        body: Center(
          child: Text('Hashed password: $_hash\n'),
        ),
      ),
    );
  }
}
