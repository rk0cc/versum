import 'package:meta/meta.dart' show sealed, protected;

import 'semver.dart' show SemVer;

/// Indicate which operators of [SemVer] used ([SemVer.>], [SemVer.<],
/// [SemVer.>=] and [SemVer.<=]) in [VersionConstraintNode.inRange].
enum VersionConstraintOperator {
  /// Indicate the given [SemVer] must be greater than
  /// [VersionConstraintNode.affectedVersion].
  greater,

  /// Indicate the given [SemVer] must be greater or equal with
  /// [VersionConstraintNode.affectedVersion].
  greater_or_equal,

  /// Indicate the given [SemVer] must be lower than
  /// [VersionConstraintNode.affectedVersion].
  lower_or_equal,

  /// Indicate the given [SemVer] must be lower or equal with
  /// [VersionConstraintNode.affectedVersion].
  lower
}

bool _sameVersion(SemVer s1, SemVer s2) =>
    s1.major == s2.major &&
    s1.minor == s2.minor &&
    s1.patch == s2.patch &&
    s1.build == s2.build;

/// Extension for [VersionConstraintOperator] which giving condition according
/// to the operator.
extension _VersionConstraintOperator on VersionConstraintOperator {
  /// Check the [provided] one is matched [constraint]'s describe.
  ///
  /// If [excludePreRelease] set as `true`, it return `false` when [provided]
  /// [SemVer] contains [SemVer.preRelease] but not mentioned in [constraint].
  /// However, when [constraint] has non-nulled [SemVer.preRelease], it does not
  /// affect the condition.
  bool matched(SemVer constraint, SemVer provided, bool excludePreRelease) {
    if (excludePreRelease &&
        constraint.preRelease == null &&
        _sameVersion(constraint, provided)) return false;
    switch (this) {
      case VersionConstraintOperator.greater:
        return constraint > provided;
      case VersionConstraintOperator.greater_or_equal:
        return constraint >= provided;
      case VersionConstraintOperator.lower_or_equal:
        return constraint <= provided;
      case VersionConstraintOperator.lower:
        return constraint < provided;
    }
  }

  /// Return a [String] which repersent the symbol of operator.
  String get symbol {
    switch (this) {
      case VersionConstraintOperator.greater:
        return ">";
      case VersionConstraintOperator.greater_or_equal:
        return ">=";
      case VersionConstraintOperator.lower_or_equal:
        return "<=";
      case VersionConstraintOperator.lower:
        return "<";
    }
  }
}

/// A record repersenting entire version constraint's metadata.
mixin VersionConstraintRecord {
  /// Giving a [version] that is stastified with this record.
  ///
  /// If [excludePreRelease] set as `true`, the result will consider the given
  /// [version]'s pre-release field is nulled already.
  bool inRange(SemVer version, {bool excludePreRelease = true});
}

/// Extended [VersionConstraintRecord] which indicating which objects allows
/// to assign in [OrMultipleVersionConstraint].
///
/// This mixin does not implemented additional functions and fields. Just uses
/// to be indicated eligible type of [VersionConstraintRecord].
mixin OrConstraintRecordSection on VersionConstraintRecord {}

/// Smallest entity of [VersionConstraintRecord] that contains [SemVer] and
/// [VersionConstraintOperator] only and enough to uses for giving constraint
/// result.
@sealed
class VersionConstraintNode
    with VersionConstraintRecord, OrConstraintRecordSection {
  /// Indicate a version to be affected.
  final SemVer affectedVersion;
  final VersionConstraintOperator constraintOperator;

  VersionConstraintNode._(this.affectedVersion, this.constraintOperator);

  factory VersionConstraintNode(
          {required SemVer affectedVersion,
          required VersionConstraintOperator constraintOperator}) =>
      VersionConstraintNode._(affectedVersion, constraintOperator);

  bool inRange(SemVer version, {bool excludePreRelease = true}) =>
      constraintOperator.matched(affectedVersion, version, excludePreRelease);

  String get traditionalVersionConstraint =>
      "${constraintOperator.symbol}${affectedVersion}";
}

abstract class MultipleVersionConstraintNode<T extends VersionConstraintRecord>
    with VersionConstraintRecord {
  final List<T> _constraints;

  MultipleVersionConstraintNode._([List<T>? constraints])
      : _constraints = List.unmodifiable(constraints ?? []);

  List<T> get constraints => _constraints;
}

@sealed
class AndMultipleVersionConstraint
    extends MultipleVersionConstraintNode<VersionConstraintNode>
    with VersionConstraintRecord, OrConstraintRecordSection {
  @protected
  AndMultipleVersionConstraint([List<VersionConstraintNode>? constraints])
      : super._(constraints);

  @override
  bool inRange(SemVer version, {bool excludePreRelease = true}) =>
      _constraints.every(
          (vcs) => vcs.inRange(version, excludePreRelease: excludePreRelease));
}

@sealed
class OrMultipleVersionConstraint
    extends MultipleVersionConstraintNode<OrConstraintRecordSection>
    with VersionConstraintRecord {
  @protected
  OrMultipleVersionConstraint([List<OrConstraintRecordSection>? constraints])
      : super._(constraints);

  @override
  bool inRange(SemVer version, {bool excludePreRelease = true}) => _constraints
      .any((vcs) => vcs.inRange(version, excludePreRelease: excludePreRelease));
}

abstract class VersionConstraint<B extends MultipleVersionConstraintNode> {
  final String? rawConstraint;
  final B constraintsContainer;

  @protected
  VersionConstraint(this.rawConstraint, this.constraintsContainer);

  bool stastified(SemVer version, {bool excludePreRelease = true}) =>
      constraintsContainer.inRange(version,
          excludePreRelease: excludePreRelease);
}
