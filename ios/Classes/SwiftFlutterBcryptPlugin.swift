import Flutter
import UIKit
import BCryptSwift

public class SwiftFlutterBcryptPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_bcrypt", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterBcryptPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method{
        
    case "hashPw":
        guard let args = call.arguments as? [String: String] else {
            fatalError("args are badly formatted")
        }
        
        let password = args["password"]!
        let salt = args["salt"]!
    
        result(BCryptSwift.hashPassword(password, withSalt: salt))
        
        break
    case "salt":
        result(BCryptSwift.generateSalt())
        break
    case "saltWithRounds":
        guard let args = call.arguments as? [String: UInt] else {
            fatalError("args are badly formatted")
        }
        
        let rounds = args["rounds"]!
        result(BCryptSwift.generateSaltWithNumberOfRounds(rounds))

        break
    case "verify":
        guard let args = call.arguments as? [String: String] else {
            fatalError("args are badly formatted")
        }
        
        let password = args["password"]!
        let hash = args["hash"]!
        
        result(BCryptSwift.verifyPassword(password, matchesHash: hash))
        
        break
    default:
        result(FlutterMethodNotImplemented)
        
    }
  }
}
