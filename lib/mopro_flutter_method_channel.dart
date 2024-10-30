import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mopro_flutter_platform_interface.dart';

/// An implementation of [MoproFlutterPlatform] that uses method channels.
class MethodChannelMoproFlutter extends MoproFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mopro_flutter', JSONMethodCodec());

  @override
  Future<Map<String, dynamic>?> generateProof(
      String zkeyPath, Map<String, List<String>> inputs) async {
    final proofResult = await methodChannel
        .invokeMethod<Map<String, dynamic>>('generateProof', {
      'zkeyPath': zkeyPath,
      'inputs': inputs,
    });
    print("proofResult: $proofResult");
    return proofResult;
  }
}
