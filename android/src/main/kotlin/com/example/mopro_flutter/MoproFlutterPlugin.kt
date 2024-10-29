package com.example.mopro_flutter

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import uniffi.mopro.generateCircomProof

import org.json.JSONObject
import android.util.Log
import io.flutter.plugin.common.JSONMethodCodec
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import uniffi.mopro.GenerateProofResult
import uniffi.mopro.toEthereumInputs
import uniffi.mopro.toEthereumProof

/** MoproFlutterPlugin */
class MoproFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mopro_flutter", JSONMethodCodec.INSTANCE)
    channel.setMethodCallHandler(this)
  }

  fun JSONObject.toMap(): Map<String, List<String>> {
    val map = mutableMapOf<String, List<String>>()
    this.keys().forEach { key ->
      val list = mutableListOf<String>()
      val jsonArray = this.getJSONArray(key)
      for (i in 0 until jsonArray.length()) {
        list.add(jsonArray.getString(i))
      }
      map[key] = list
    }
    return map
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "generateProof") {
      val zkeyPath = call.argument<String>("zkeyPath") ?: return result.error("ARGUMENT_ERROR", "Missing zkeyPath", null)

      val inputsJson = call.argument<JSONObject>("inputs") ?: return result.error("ARGUMENT_ERROR", "Missing inputs", null)
      val inputs = inputsJson.toMap() as Map<String, List<String>>
 
      val res: GenerateProofResult = generateCircomProof(zkeyPath, inputs)
      val proof = toEthereumProof(res.proof)
      val convertedInputs = toEthereumInputs(res.inputs)
      
      Log.d("generateProof", "$res")

        // Build the JSON response
        val json = JSONObject().apply {
            put("proof", Json.encodeToString(proof))
            put("inputs", Json.encodeToString(convertedInputs))
        }

        // Send the JSON string back to Flutter
        result.success(
          json
        )
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
