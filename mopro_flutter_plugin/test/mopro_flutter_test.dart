import 'package:flutter_test/flutter_test.dart';
import 'package:mopro_flutter/mopro_flutter.dart';
import 'package:mopro_flutter/mopro_flutter_platform_interface.dart';
import 'package:mopro_flutter/mopro_flutter_method_channel.dart';
import 'package:mopro_flutter/mopro_types.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMoproFlutterPlatform
    with MockPlatformInterfaceMixin
    implements MoproFlutterPlatform {
  @override
  Future<GenerateProofResult?> generateProof(
          String zkeyPath, Map<String, List<String>> inputs) =>
      Future.value(GenerateProofResult(
        ProofCalldata(
          G1Point("1", "2"),
          G2Point(["1", "2"], ["3", "4"]),
          G1Point("3", "4"),
        ),
        ["3", "5"],
      ));
}

void main() {
  final MoproFlutterPlatform initialPlatform = MoproFlutterPlatform.instance;

  test('$MethodChannelMoproFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMoproFlutter>());
  });

  test('getPlatformVersion', () async {
    MoproFlutter moproFlutterPlugin = MoproFlutter();
    MockMoproFlutterPlatform fakePlatform = MockMoproFlutterPlatform();
    MoproFlutterPlatform.instance = fakePlatform;

    var inputs = <String, List<String>>{};
    inputs["a"] = ["3"];
    inputs["b"] = ["5"];
    expect(
        await moproFlutterPlugin.generateProof(
            "multiplier2_final.zkey", inputs),
        GenerateProofResult(
          ProofCalldata(
            G1Point("1", "2"),
            G2Point(["1", "2"], ["3", "4"]),
            G1Point("3", "4"),
          ),
          ["3", "5"],
        ));
  });
}
