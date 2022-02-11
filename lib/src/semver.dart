import 'package:meta/meta.dart' show sealed;
import 'package:quiver/core.dart' show hashObjects;

@sealed
class SemVer implements Comparable<SemVer> {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? build;

  SemVer._(this.major, this.minor, this.patch, [this.preRelease, this.build]);

  factory SemVer(
      {required int major,
      required int minor,
      required int patch,
      String? preRelease,
      String? build}) {
    SemVer sv = SemVer._(major, minor, patch, preRelease, build);

    if (!validSemVer(sv.toString()))
      throw InvalidSemVerException._(sv.toString());

    return sv;
  }

  factory SemVer.parse(String version) {
    if (!validSemVer(version)) throw InvalidSemVerException._(version);

    RegExpMatch match = _pattern.firstMatch(version)!;

    return SemVer._(int.parse(match.group(1)!), int.parse(match.group(2)!),
        int.parse(match.group(3)!), match.group(4), match.group(5));
  }

  @override
  int compareTo(SemVer o) {
    // Compare major
    if (major > o.major)
      return 1;
    else if (major < o.major) return -1;

    // Compare minor
    if (minor > o.minor)
      return 1;
    else if (minor < o.minor) return -1;

    // Compare patch
    if (patch > o.patch)
      return 1;
    else if (patch < o.patch) return -1;

    // Compare Pre-release
    if (preRelease != null && o.preRelease != null) {
      int pdiff = preRelease!.compareTo(o.preRelease!);

      if (pdiff != 0) return pdiff < 0 ? -1 : 1;
    } else if (preRelease != null)
      return -1;
    else if (o.preRelease != null) return 1;

    // Compare build
    if (build != null && o.build != null) {
      int bdiff = build!.compareTo(o.build!);

      if (bdiff != 0) return bdiff < 0 ? 1 : -1;
    } else if (build != null)
      return 1;
    else if (o.build != null) return -1;

    // Same semver
    return 0;
  }

  @override
  int get hashCode => hashObjects([major, minor, patch, preRelease, build]);

  @override
  bool operator ==(Object o) => o is SemVer && compareTo(o) == 0;

  bool operator >(SemVer o) => compareTo(o) > 0;

  bool operator <(SemVer o) => compareTo(o) < 0;

  @override
  String toString() {
    String buf = "${major}.${minor}.${patch}";

    if (preRelease != null) buf += "-${preRelease}";
    if (build != null) buf += "+${build}";

    return buf;
  }

  static bool validSemVer(String version) => _pattern.hasMatch(version);

  static RegExp get _pattern => RegExp(
      r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$",
      dotAll: true,
      caseSensitive: true);
}

@sealed
class InvalidSemVerException implements Exception {
  final String _isv;
  final String message;

  InvalidSemVerException._(this._isv,
      {this.message = "Applied version is not following semver standard."});

  @override
  String toString() {
    return "InvalidaSemVerException: ${message}\n\nApplied versioning: ${_isv}\n\n";
  }
}
