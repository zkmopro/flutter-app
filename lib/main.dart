import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mopro_flutter/mopro_flutter.dart';
import 'package:mopro_flutter/mopro_types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GenerateProofResult? _proofResult;
  final _moproFlutterPlugin = MoproFlutter();
  bool isProving = false;
  PlatformException? _error;

  // Controllers to handle user input
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerA.text = "5";
    _controllerB.text = "3";
  }

  @override
  Widget build(BuildContext context) {
    // The inputs is a base64 string
    var inputs = _proofResult?.inputs ?? "";
    // The proof is a base64 string
    var proof = _proofResult?.proof ?? "";
    // Decode the proof and inputs to see the actual values

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter App With MoPro'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isProving) const CircularProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_error.toString()),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerA,
                  decoration: const InputDecoration(
                    labelText: "Public input `a`",
                    hintText: "For example, 5",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerB,
                  decoration: const InputDecoration(
                    labelText: "Private input `b`",
                    hintText: "For example, 3",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        onPressed: () async {
                          if (_controllerA.text.isEmpty ||
                              _controllerB.text.isEmpty ||
                              isProving) {
                            return;
                          }
                          setState(() {
                            isProving = true;
                          });

                          FocusManager.instance.primaryFocus?.unfocus();
                          GenerateProofResult? proofResult;
                          PlatformException? error;
                          // Platform messages may fail, so we use a try/catch PlatformException.
                          // We also handle the message potentially returning null.
                          try {
                            var inputs =
                                '{"a":["${_controllerA.text}"],"b":["${_controllerB.text}"]}';
                            proofResult =
                                await _moproFlutterPlugin.generateProof(
                                    "assets/multiplier2_final.zkey", inputs);
                            setState(() {
                              isProving = false;
                            });
                          } on PlatformException catch (e) {
                            print("Error: $e");
                            error = e;
                            proofResult = null;
                          }

                          // If the widget was removed from the tree while the asynchronous platform
                          // message was in flight, we want to discard the reply rather than calling
                          // setState to update our non-existent appearance.
                          if (!mounted) return;

                          setState(() {
                            _proofResult = proofResult;
                            _error = error;
                          });
                        },
                        child: const Text(
                          "Generate Proof",
                        )),
                  ),
                ],
              ),
              if (_proofResult != null)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Proof inputs: $inputs'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Proof: $proof'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
