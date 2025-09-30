// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mopro_flutter_bindings/src/rust/third_party/test_e2e.dart';
import 'package:mopro_flutter_bindings/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => await RustLib.init());

  testWidgets('Circom Proof Test', (WidgetTester tester) async {
    const inputs = "{\"a\":[\"3\"],\"b\":[\"5\"]}";
    final zkeyPath =
        await copyAssetToFileSystem('assets/multiplier2_final.zkey');
    final CircomProofResult proofResult = await generateCircomProof(
        zkeyPath: zkeyPath, circuitInputs: inputs, proofLib: ProofLib.arkworks);
    final bool isValid = await verifyCircomProof(
        zkeyPath: zkeyPath,
        proofResult: proofResult,
        proofLib: ProofLib.arkworks);
    expect(isValid, isTrue);
  });

  testWidgets('Halo2 Proof Test', (WidgetTester tester) async {
    var inputs = {
      "out": ["55"]
    };
    final srsPath =
        await copyAssetToFileSystem('assets/plonk_fibonacci_srs.bin');
    final pkPath = await copyAssetToFileSystem('assets/plonk_fibonacci_pk.bin');
    final Halo2ProofResult proofResult = await generateHalo2Proof(
      srsPath: srsPath,
      pkPath: pkPath,
      circuitInputs: inputs,
    );
    final vkPath = await copyAssetToFileSystem('assets/plonk_fibonacci_vk.bin');
    final bool isValid = await verifyHalo2Proof(
      srsPath: srsPath,
      vkPath: vkPath,
      proof: proofResult.proof,
      publicInput: proofResult.inputs,
    );
    expect(isValid, isTrue);
  });

  testWidgets('Noir Proof Test', (WidgetTester tester) async {
    var inputs = ["5", "3"];
    // Constants for Noir proof generation
    const bool onChain = true; // Use Keccak for Solidity compatibility
    const bool lowMemoryMode = false;
    final circuitPath =
        await copyAssetToFileSystem('assets/noir_multiplier2.json');
    final srsPath = await copyAssetToFileSystem('assets/noir_multiplier2.srs');
    final vkAsset = await rootBundle.load('assets/noir_multiplier2.vk');
    final vk = vkAsset.buffer.asUint8List();
    final proofResult = await generateNoirProof(
        circuitPath: circuitPath,
        srsPath: srsPath,
        inputs: inputs,
        onChain: onChain,
        vk: vk,
        lowMemoryMode: lowMemoryMode);
    final bool isValid = await verifyNoirProof(
      circuitPath: circuitPath,
      proof: proofResult,
      onChain: onChain,
      vk: vk,
      lowMemoryMode: lowMemoryMode,
    );
    expect(isValid, isTrue);
  });
}

/// Copies an asset to a file and returns the file path
Future<String> copyAssetToFileSystem(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final directory = await getApplicationDocumentsDirectory();
  final filename = assetPath.split('/').last;
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file.path;
}
