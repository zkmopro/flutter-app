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
  Future<CircomProofResult?> generateCircomProof(
      String zkeyPath, String inputs) async {
    final proofResult = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('generateCircomProof', {
      'zkeyPath': zkeyPath,
      'inputs': inputs,
    });

    if (proofResult == null) {
      return null;
    }

    var circomProofResult = CircomProofResult.fromMap(proofResult);

    return circomProofResult;
  }

  @override
  Future<bool> verifyCircomProof(String zkeyPath, CircomProofResult proof) async {
    final result = await methodChannel.invokeMethod<bool>('verifyCircomProof', {
      'zkeyPath': zkeyPath,
      'proof': proof.toMap(),
    });
    return result ?? false;
  }

  @override
  Future<Halo2ProofResult?> generateHalo2Proof(String srsPath, String pkPath, Map<String, List<String>> inputs) async {
    final proofResult = await methodChannel.invokeMethod<Map<Object?, Object?>>('generateHalo2Proof', {
      'srsPath': srsPath,
      'pkPath': pkPath,
      'inputs': inputs,
    });

    if (proofResult == null) {
      return null;
    }

    var halo2ProofResult = Halo2ProofResult.fromMap(proofResult);
    return halo2ProofResult;
  }

  @override
  Future<bool> verifyHalo2Proof(String srsPath, String vkPath, Uint8List proof, Uint8List inputs) async {
    print("verifyHalo2Proof: srsPath: $srsPath, vkPath: $vkPath, proof: ${proof.length}, inputs: ${inputs.length}");
    final result = await methodChannel.invokeMethod<bool>('verifyHalo2Proof', {
      'srsPath': srsPath,
      'vkPath': vkPath,
      'proof': proof,
      'inputs': inputs,
    });
    return result ?? false;
  }
}
