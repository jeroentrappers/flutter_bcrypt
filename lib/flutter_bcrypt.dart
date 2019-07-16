import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class FlutterBcrypt {
  static const MethodChannel _channel =
      const MethodChannel('flutter_bcrypt');

  static Future<String> hashPw({@required String password, @required String salt}) async =>
    await _channel.invokeMethod('hashPw', {'password': password, 'salt': salt});

  static Future<String> salt() async =>
      await _channel.invokeMethod('salt', {'rounds' : 6});

  static Future<String> saltWithRounds({@required int rounds}) async =>
      await _channel.invokeMethod('saltWithRounds', {'rounds': rounds});

  static Future<bool> verify({@required String password, @required String hash}) async =>
      await _channel.invokeMethod('verify', {'password': password, 'hash': hash});
}
