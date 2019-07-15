package be.appmire.flutter_bcrypt

import android.util.Log

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import at.favre.lib.crypto.bcrypt.BCrypt
import at.favre.lib.crypto.bcrypt.Radix64Encoder
import java.nio.charset.StandardCharsets

class FlutterBcryptPlugin: MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_bcrypt")
      channel.setMethodCallHandler(FlutterBcryptPlugin())
    }
  }

  fun MethodCall.password(): String? {
    return this.argument("password")
  }

  fun MethodCall.salt(): String? {
    return this.argument("salt")
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    try {
      when (call.method) {
        "hashPw" -> {

          val salt: String = call.salt()!!
          val realSalt: String
          val rounds: Int
          var off : Int = 0
          var minor : Char = 'b'
          val password: String = call.password()!!
          var version : BCrypt.Version = BCrypt.Version.VERSION_2B

          if (salt[0] != '\$' || salt[1] != '2') {
            throw Exception("Invalid salt version");
          }
          if (salt[2] == '\$') {
            off = 3;
          } else {
            minor = salt[2];
            if ((minor != 'a' && minor != 'b' && minor != 'y') || salt[3] != '\$') {
              throw Exception("Invalid salt revision");
            }
            off = 4;
          }

          // Extract number of rounds
          if (salt[off + 2] > '\$') {
            throw Exception("Missing salt rounds");
          }
          rounds = Integer.parseInt(salt.substring(off, off + 2));

          realSalt = salt.substring(off + 3, off + 25);

          if('a' == minor )
          {
            version = BCrypt.Version.VERSION_2A;
          }
          else if( 'b' == minor) {
            version = BCrypt.Version.VERSION_2B;
          }

          val hash = BCrypt.with(version).hash(rounds, Radix64Encoder.Default().decode(realSalt.toByteArray(Charsets.UTF_8)), password.toByteArray(Charsets.UTF_8))

          val r = String(hash, Charsets.UTF_8);

          result.success(r)
        }
        else -> result.notImplemented()
      }
    } catch (e: Exception) {
      Log.e("flutter_bcrypt", e.message)
      result.error("flutter_bcrypt", e.message, e)
    }
  }
}
