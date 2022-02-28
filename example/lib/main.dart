import 'package:versum/versum.dart';
import 'example.dart';

void main() {
  // Parse semver
  SemVer construct = new SemVer(major: 1, minor: 2, patch: 3);
  SemVer parse = SemVer.parse("1.2.3");

  // Version compare
  bool equal = construct == parse;
  bool gt = construct > SemVer(major: 2);

  // Set version constraint
  VersionConstraint exampleVersionConstraint =
      ExampleVersionConstraint(">=1.0.0 <2.0.0");

  // Check is in range
  bool isInRange = exampleVersionConstraint.stastified(construct);

  // Include pre-release
  bool isInRangeWithPrerelease =
      exampleVersionConstraint.stastified(parse, excludePreRelease: false);
}
