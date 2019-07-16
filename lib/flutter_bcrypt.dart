import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class FlutterBcrypt {
  static const MethodChannel _channel = const MethodChannel('flutter_bcrypt');

  /// Create passworde hash for given password and salt.
  /// Password must be a plain UTF-8 compatible String.
  /// Salt must be a string in Modular Crypt Format with $ separators
  /// for example r'$2b$06$C6UzMDM.H6dfI/f/IKxGhu'
  static Future<String> hashPw(
          {@required String password, @required String salt}) async =>
      await _channel
          .invokeMethod('hashPw', {'password': password, 'salt': salt});

  /// Generate a 16 byte salt with 6 rounds of cost in Modular Crypt Format.
  static Future<String> salt() async =>
      await _channel.invokeMethod('salt', {'rounds': 6});

  /// Generate a salt with a given cost. Cost must be between 4 and 31.
  static Future<String> saltWithRounds({@required int rounds}) async =>
      await _channel.invokeMethod('saltWithRounds', {'rounds': rounds});

  /// Verify if the given password matches the given hash.
  /// Password must be a plain UTF-8 compatible String
  /// Hash must be provided in Modular Crypt Format. Eg.
  /// $2y$06$doGnefu9cbLkJTn8sef7U.dynHJFe5hS6xp7vLWb2Zu7e8cOuMVmS
  /// This includes the version, complexity and 16 bytes of salt.
  static Future<bool> verify(
          {@required String password, @required String hash}) async =>
      await _channel
          .invokeMethod('verify', {'password': password, 'hash': hash});
}
