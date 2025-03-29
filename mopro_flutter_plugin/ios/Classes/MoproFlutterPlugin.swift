import Flutter
import moproFFI
import UIKit

public class MoproFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mopro_flutter", binaryMessenger: registrar.messenger())
        let instance = MoproFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "generateProof":
            guard let args = call.arguments as? [String: Any],
                  let zkeyPath = args["zkeyPath"] as? String,
                  let inputs = args["inputs"] as? String
            else {
                result(FlutterError(code: "ARGUMENT_ERROR", message: "Missing arguments", details: nil))
                return
            }

            do {
                // Call the function from mopro.swift
                let proofResult = try generateCircomProof(zkeyPath: zkeyPath, circuitInputs: inputs, proofLib: ProofLib.arkworks)
                let proof = proofResult.proof
                let inputs = proofResult.inputs
               
                let proofList: [[String: Any]] = [
                    ["x": proof.a.x, "y": proof.a.y],
                    ["x": proof.b.x, "y": proof.b.y],
                    ["x": proof.c.x, "y": proof.c.y]
                ]
                
                let resMap: [String: Any] = [
                    "proof": proofList,
                    "inputs": inputs
                ]
                
                // Return the proof and inputs as a map supported by the StandardMethodCodec
                result(resMap)
            } catch {
                result(FlutterError(code: "PROOF_GENERATION_ERROR", message: "Failed to generate proof", details: error.localizedDescription))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
