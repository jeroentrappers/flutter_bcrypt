import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class FlutterBcrypt {
  static const MethodChannel _channel =
      const MethodChannel('flutter_bcrypt');

  static Future<String> hashPw({@required String password, @required String salt}) async =>
    await _channel.invokeMethod('hashPw', {'password': password, 'salt': salt});
}
