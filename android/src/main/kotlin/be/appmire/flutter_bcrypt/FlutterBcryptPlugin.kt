package be.appmire.flutter_bcrypt

import android.util.Log
import at.favre.lib.bytes.Bytes

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import at.favre.lib.crypto.bcrypt.BCrypt
import at.favre.lib.crypto.bcrypt.BCrypt.SALT_LENGTH
import at.favre.lib.crypto.bcrypt.Radix64Encoder
import java.nio.ByteBuffer
import java.security.SecureRandom
import java.util.*

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

  fun MethodCall.hash(): String? {
    return this.argument("hash")
  }

  fun MethodCall.rounds(): Int? {
    return this.argument("rounds")
  }

  fun saltFromHashData(hashData: BCrypt.HashData): String {
    val encoder = Radix64Encoder.Default();

    val saltEncoded = encoder.encode(hashData.rawSalt)
    val hashEncoded = encoder.encode(hashData.rawHash)
    val costFactorBytes = String.format(Locale.US, "%02d", hashData.cost).toByteArray(Charsets.UTF_8)
    val separator = '$'.toByte();

    try {
      val byteBuffer = ByteBuffer.allocate(hashData.version.versionIdentifier.size +
              costFactorBytes.size + 3 + saltEncoded.size + hashEncoded.size)
      byteBuffer.put(separator)
      byteBuffer.put(hashData.version.versionIdentifier)
      byteBuffer.put(separator)
      byteBuffer.put(costFactorBytes)
      byteBuffer.put(separator)
      byteBuffer.put(saltEncoded)
      return String(byteBuffer.array(), Charsets.UTF_8)
    } finally {
      Bytes.wrapNullSafe(saltEncoded).mutable().secureWipe()
      Bytes.wrapNullSafe(hashEncoded).mutable().secureWipe()
      Bytes.wrapNullSafe(costFactorBytes).mutable().secureWipe()
    }
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

        "salt" -> {
          val salt = BCrypt.HashData(6, BCrypt.Version.VERSION_2B, Bytes.random(SALT_LENGTH, SecureRandom()).array(),Bytes.random(23, SecureRandom()).array());
          result.success(saltFromHashData(salt))
        }
        "saltWithRounds" -> {
          val rounds = call.rounds()!!
          val salt = BCrypt.HashData(rounds, BCrypt.Version.VERSION_2B, Bytes.random(SALT_LENGTH, SecureRandom()).array(),Bytes.random(23, SecureRandom()).array());
          result.success(saltFromHashData(salt))
        }
        "verify" -> {
          val password: String = call.password()!!
          val hash: String = call.hash()!!
          val r = BCrypt.verifyer().verify(password.toCharArray(), hash.toByteArray(Charsets.UTF_8))
          result.success(r.verified)
        }


        else -> result.notImplemented()
      }
    } catch (e: Exception) {
      Log.e("flutter_bcrypt", e?.message ?: "Error occured")
      result.error("flutter_bcrypt", e.message, e)
    }


  }
}
