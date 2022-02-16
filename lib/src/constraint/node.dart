import 'package:meta/meta.dart' show sealed;
import 'package:quiver/core.dart';

import '../semver.dart' show SemVer;

abstract class VersionConstraint<E extends Enum> {
  String? get rawConstraint;
  E get constraintPattern;
  SemVer? get from;
  SemVer? get to;
}
