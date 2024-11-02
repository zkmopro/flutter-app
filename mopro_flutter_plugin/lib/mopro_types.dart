class G1Point {
  final String x;
  final String y;

  G1Point(this.x, this.y);

  @override
  String toString() {
    return "G1Point(\nx: $x, \ny: $y)";
  }
}

class G2Point {
  final List<String> x;
  final List<String> y;

  G2Point(this.x, this.y);

  @override
  String toString() {
    return "G2Point(\nx: $x, \ny: $y)";
  }
}

class ProofCalldata {
  final G1Point a;
  final G2Point b;
  final G1Point c;

  ProofCalldata(this.a, this.b, this.c);

  @override
  String toString() {
    return "ProofCalldata(\na: $a, \nb: $b, \nc: $c)";
  }
}

class GenerateProofResult {
  final ProofCalldata proof;
  final List<String> inputs;

  GenerateProofResult(this.proof, this.inputs);

  factory GenerateProofResult.fromMap(Map<Object?, Object?> proofResult) {
    var proof = proofResult["proof"] as List;
    var inputs = proofResult["inputs"] as List;
    return GenerateProofResult(
        ProofCalldata(
            G1Point(proof[0]["x"] as String, proof[0]["y"] as String),
            G2Point(proof[1]["x"].cast<String>(), proof[1]["y"].cast<String>()),
            G1Point(proof[2]["x"] as String, proof[2]["y"] as String)),
        inputs.cast<String>());
  }
}
