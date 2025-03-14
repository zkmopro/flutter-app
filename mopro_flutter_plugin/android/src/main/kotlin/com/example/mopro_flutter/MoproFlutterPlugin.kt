package com.example.mopro_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import uniffi.mopro.generateCircomProof

import io.flutter.plugin.common.StandardMethodCodec
import uniffi.mopro.ProofCalldata
import uniffi.mopro.toEthereumInputs
import uniffi.mopro.toEthereumProof
import uniffi.mopro.ProofLib
/** MoproFlutterPlugin */
class MoproFlutterPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "mopro_flutter",
            StandardMethodCodec.INSTANCE
        )
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "generateProof") {
            val zkeyPath = call.argument<String>("zkeyPath") ?: return result.error(
                "ARGUMENT_ERROR",
                "Missing zkeyPath",
                null
            )

            val inputs =
                call.argument<String>("inputs") ?: return result.error(
                    "ARGUMENT_ERROR",
                    "Missing inputs",
                    null
                )

            val res = generateCircomProof(zkeyPath, inputs, ProofLib.ARKWORKS)
            val proof: ProofCalldata = toEthereumProof(res.proof)
            val convertedInputs: List<String> = toEthereumInputs(res.inputs)

            val proofList = listOf(
                mapOf(
                    "x" to proof.a.x,
                    "y" to proof.a.y
                ), mapOf(
                    "x" to proof.b.x,
                    "y" to proof.b.y
                ), mapOf(
                    "x" to proof.c.x,
                    "y" to proof.c.y
                )
            )

            // Return the proof and inputs as a map supported by the StandardMethodCodec
            val resMap = mapOf(
                "proof" to proofList,
                "inputs" to convertedInputs
            )

            result.success(
                resMap
            )
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
