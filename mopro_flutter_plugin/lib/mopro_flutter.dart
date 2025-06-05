import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mopro_flutter/mopro_types.dart';
import 'package:path_provider/path_provider.dart';

import 'mopro_flutter_platform_interface.dart';

class MoproFlutter {
  Future<String> copyAssetToFileSystem(String assetPath) async {
    // Load the asset as bytes
    final byteData = await rootBundle.load(assetPath);
    // Get the app's document directory (or other accessible directory)
    final directory = await getApplicationDocumentsDirectory();
    //Strip off the initial dirs from the filename
    assetPath = assetPath.split('/').last;

    final file = File('${directory.path}/$assetPath');

    // Write the bytes to a file in the file system
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file.path; // Return the file path
  }

  Future<CircomProofResult?> generateCircomProof(
      String zkeyFile, String inputs) async {
    return await copyAssetToFileSystem(zkeyFile).then((path) async {
      return await MoproFlutterPlatform.instance.generateCircomProof(path, inputs);
    });
  }

  Future<bool> verifyCircomProof(String zkeyFile, CircomProofResult proof) async {
    return await copyAssetToFileSystem(zkeyFile).then((path) async {
      return await MoproFlutterPlatform.instance.verifyCircomProof(path, proof);
    });
  }
}
