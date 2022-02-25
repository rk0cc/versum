import 'package:test/test.dart';
import 'package:versum/build.dart';
import 'package:versum/versum.dart';

void main() {
  group("Multiple constraint test", () {
    test("and constraint", () {
      AndMultipleVersionConstraint amvc = AndMultipleVersionConstraint([
        new VersionConstraintNode(
            affectedVersion: SemVer.parse("1.0.0"),
            constraintOperator: VersionConstraintOperator.greater_or_equal),
        new VersionConstraintNode(
            affectedVersion: SemVer.parse("2.0.0"),
            constraintOperator: VersionConstraintOperator.lower)
      ]);
      expect(amvc.inRange(SemVer.parse("1.0.1")), isTrue);
      expect(amvc.inRange(SemVer.parse("1.0.0")), isTrue);
      expect(amvc.inRange(SemVer.parse("2.0.0-alpha")), isFalse);
      expect(
          amvc.inRange(SemVer.parse("2.0.0-alpha"), excludePreRelease: false),
          isTrue);
    });
    test("or constraint", () {
      OrMultipleVersionConstraint omvc = OrMultipleVersionConstraint([
        new VersionConstraintNode(
            affectedVersion: SemVer.parse("2.0.0"),
            constraintOperator: VersionConstraintOperator.lower),
        new VersionConstraintNode(
            affectedVersion: SemVer.parse("4.2.0"),
            constraintOperator: VersionConstraintOperator.greater)
      ]);

      expect(omvc.inRange(SemVer(major: 1, minor: 2, patch: 0)), isTrue);
      expect(omvc.inRange(SemVer.parse("2.3.0")), isFalse);
      expect(omvc.inRange(SemVer.parse("3.2.9")), isFalse);
      expect(omvc.inRange(SemVer.parse("4.2.1")), isTrue);
      expect(omvc.inRange(SemVer(major: 99, minor: 0, patch: 0)), isTrue);
    });
  });
}
