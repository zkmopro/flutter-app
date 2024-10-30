import Flutter
import moproFFI
import UIKit

public class MoproFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mopro_flutter", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec())
        let instance = MoproFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "generateProof":
            guard let args = call.arguments as? [String: Any],
                  let zkeyPath = args["zkeyPath"] as? String,
                  let inputs = args["inputs"] as? [String: [String]]
            else {
                result(FlutterError(code: "ARGUMENT_ERROR", message: "Missing arguments", details: nil))
                return
            }

            do {
                // Call the function from mopro.swift
                let proofResult = try generateCircomProof(zkeyPath: zkeyPath, circuitInputs: inputs)
                let proof = toEthereumProof(proof: proofResult.proof)
                let convertedInputs = toEthereumInputs(inputs: proofResult.inputs)
                let proofJson = try JSONEncoder().encode(proof)
                let inputsJson = try JSONEncoder().encode(convertedInputs)

                if let proofString = String(data: proofJson, encoding: .utf8), let inputsString = String(data: inputsJson, encoding: .utf8) {
                    let response: [String: String] = [
                        "proof": proofString,
                        "inputs": inputsString
                    ]
                    result(response)
                } else {
                    result(FlutterError(code: "PROOF_GENERATION_ERROR", message: "Failed to convert proof to a string.", details: nil))
                }

                // Return the response to Flutter

            } catch {
                result(FlutterError(code: "PROOF_GENERATION_ERROR", message: "Failed to generate proof", details: error.localizedDescription))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
