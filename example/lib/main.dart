import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:dbcrypt/dbcrypt.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _hash = 'Unknown';
  String _hash2 = 'TODO';

  @override
  void initState() {
    super.initState();
    hash();
  }

  Future<void> hash() async {
    String hash;
    String hash2;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      final stopwatch = Stopwatch()..start();

      stopwatch.reset();
      hash = await FlutterBcrypt.hashPw(
          password: r'3282aae5-f104-4639-88a3-3af9a1efb069',
          salt: r'$2b$06$C6UzMDM.H6dfI/f/IKxGhu');
      print('FlutterBcrypt - hashPw after ${stopwatch.elapsed}');

      stopwatch.reset();
      hash2 = await DBCrypt().hashpw(
          r'3282aae5-f104-4639-88a3-3af9a1efb069',
          r'$2b$06$C6UzMDM.H6dfI/f/IKxGhu');
      print('DBCrypt - hashPw after ${stopwatch.elapsed}');

      print("${hash == hash2}"); // should be true

      stopwatch.reset();
      var salt = await FlutterBcrypt.salt();
      print('FlutterBcrypt salt ${stopwatch.elapsed} ' + salt);

      stopwatch.reset();
      var salt2 = DBCrypt().gensalt();
      print('DBcrypt salt ${stopwatch.elapsed} ' + salt2);

      stopwatch.reset();
      var salt10 = await FlutterBcrypt.saltWithRounds(rounds: 10);
      print("FlutterBcrypt salt10 ${stopwatch.elapsed} " + salt10);

      stopwatch.reset();
      var salt10b = DBCrypt().gensaltWithRounds(10);
      print("DBcrypt salt10 ${stopwatch.elapsed} " + salt10b);


      stopwatch.reset();
      var pwh = await FlutterBcrypt.hashPw(
          password: r'ThisIsSuperSecret', salt: salt);
      print("FlutterBcrypt pwh  ${stopwatch.elapsed}  " + pwh);

      stopwatch.reset();
      var pwh2 =  DBCrypt().hashpw( r'ThisIsSuperSecret', salt2);
      print("DBcrypt pwh2  ${stopwatch.elapsed}  " + pwh2);

      stopwatch.reset();
      var pwh10 = await FlutterBcrypt.hashPw(
          password: r'ThisIsSuperSecret', salt: salt10);
      print("FlutterBcrypt pwh10 ${stopwatch.elapsed}  " + pwh10);

      stopwatch.reset();
      var pwh10b = DBCrypt().hashpw( r'ThisIsSuperSecret', salt10b);
      print("DBcrypt pwh10b ${stopwatch.elapsed}  " + pwh10b);

      stopwatch.reset();
      var result =
          await FlutterBcrypt.verify(password: r'ThisIsSuperSecret', hash: pwh2);
      print("FlutterBcrypt result: ${stopwatch.elapsed}  " + (result ? "ok" : "nok"));

      stopwatch.reset();
      var result2 = DBCrypt().checkpw(r'ThisIsSuperSecret', pwh2);
      print("DBcrypt result: ${stopwatch.elapsed}  " + (result2 ? "ok" : "nok"));


      stopwatch.reset();
      var result10 = await FlutterBcrypt.verify(
          password: r'ThisIsSuperSecret', hash: pwh10);
      print("FlutterBcrypt result10: ${stopwatch.elapsed}  " + (result10 ? "ok" : "nok"));

      stopwatch.reset();
      var result10b = DBCrypt().checkpw(r'ThisIsSuperSecret', pwh10b);
      print("DBCrypt result10: ${stopwatch.elapsed}  " + (result10b ? "ok" : "nok"));

      stopwatch.reset();
      var resultFailed = await FlutterBcrypt.verify(
          password: r'ThisPasswordIsWrong', hash: pwh10);
      print("FlutterBcrypt resultFailed: ${stopwatch.elapsed}  " + (resultFailed ? "nok" : "ok"));

      stopwatch.reset();
      var resultFailed2 = DBCrypt().checkpw( r'ThisPasswordIsWrong', pwh10b);
      print("DBCrypt resultFailed2: ${stopwatch.elapsed}  " + (resultFailed2 ? "nok" : "ok"));


    } on PlatformException {
      hash = 'Failed to get hash.';
      hash2 = 'Failed to get hash via DBcrypt';
    }

    if (!mounted) return;

    setState(() {
      _hash = hash;
      _hash2 = hash2;
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
          child: Text('Hashed password: $_hash, $_hash2\n'),
        ),
      ),
    );
  }
}
