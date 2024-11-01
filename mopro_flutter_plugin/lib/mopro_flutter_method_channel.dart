import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mopro_flutter/mopro_types.dart';

import 'mopro_flutter_platform_interface.dart';

/// An implementation of [MoproFlutterPlatform] that uses method channels.
class MethodChannelMoproFlutter extends MoproFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mopro_flutter');

  @override
  Future<GenerateProofResult?> generateProof(
      String zkeyPath, Map<String, List<String>> inputs) async {
    final proofResult = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('generateProof', {
      'zkeyPath': zkeyPath,
      'inputs': inputs,
    });

    if (proofResult == null) {
      return null;
    }

    var generateProofResult = GenerateProofResult.fromMap(proofResult);

    return generateProofResult;
  }
}
