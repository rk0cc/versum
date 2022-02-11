import 'package:test/test.dart';
import 'package:versum/version.dart';

void main() {
  group("Version comparsion test", () {
    test("equal", () {
      expect(
          SemVer(major: 1, minor: 0, patch: 0), equals(SemVer.parse("1.0.0")));
      expect(SemVer(major: 1, minor: 0, patch: 1, preRelease: "alpha"),
          equals(SemVer.parse("1.0.1-alpha")));
      expect(SemVer(major: 1, minor: 2, patch: 3, build: "foo"),
          SemVer.parse("1.2.3+foo"));
      expect(
          SemVer(major: 2, minor: 0, patch: 0, preRelease: "beta", build: "2"),
          SemVer.parse("2.0.0-beta+2"));
    });
    test("greater", () {
      expect(SemVer(major: 1, minor: 3, patch: 0),
          greaterThan(SemVer.parse("1.2.99")));
      expect(SemVer(major: 4, minor: 6, patch: 2, preRelease: "alpha"),
          greaterThan(SemVer.parse("4.6.1")));
      expect(SemVer(major: 3, minor: 6, patch: 9),
          greaterThan(SemVer.parse("3.6.9-alpha")));
    });
  });
}
