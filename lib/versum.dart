/// Basic library which provides to accessing version and constraint data.
///
/// It includes version parsing and constraint class (it implemented by other
/// package).
library versum;

export 'src/semver.dart';
export 'src/constraints.dart' show VersionConstraint;
