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

/// Just check [s1] and [s2] is in the same major, minor and patch value.
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
        provided.preRelease != null &&
        _sameVersion(constraint, provided)) return false;
    switch (this) {
      case VersionConstraintOperator.greater:
        return constraint < provided;
      case VersionConstraintOperator.greater_or_equal:
        return constraint <= provided;
      case VersionConstraintOperator.lower_or_equal:
        return constraint >= provided;
      case VersionConstraintOperator.lower:
        return constraint > provided;
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

/// Extended [VersionConstraintRecord] which indicating the objects allows
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

  /// An [Enum] field that repersenting [affectedVersion]'s operator.
  final VersionConstraintOperator constraintOperator;

  VersionConstraintNode._(this.affectedVersion, this.constraintOperator);

  /// Construct value of [VersionConstraintNode] with given [affectedVersion]
  /// and [constraintOperator].
  factory VersionConstraintNode(
          {required SemVer affectedVersion,
          required VersionConstraintOperator constraintOperator}) =>
      VersionConstraintNode._(affectedVersion, constraintOperator);

  bool inRange(SemVer version, {bool excludePreRelease = true}) =>
      constraintOperator.matched(affectedVersion, version, excludePreRelease);

  /// Print traditional version constraint for this node.
  String get traditionalVersionConstraint =>
      "${constraintOperator.symbol}${affectedVersion}";
}

/// An abstract class of [VersionConstraintRecord] which more than one
/// [VersionConstraintRecord]s contain in this object.
abstract class MultipleVersionConstraintNode<T extends VersionConstraintRecord>
    with VersionConstraintRecord {
  final List<T> _constraints;

  MultipleVersionConstraintNode._([List<T>? constraints])
      : _constraints = List.unmodifiable(constraints ?? []);

  /// Get an [int] of [T] contains in this [MultipleVersionConstraintNode].
  int get constraintsItems => _constraints.length;
}

/// Subtype of [MultipleVersionConstraintNode] which all [constraints] items
/// must be matched.
@sealed
class AndMultipleVersionConstraint
    extends MultipleVersionConstraintNode<VersionConstraintNode>
    with VersionConstraintRecord, OrConstraintRecordSection {
  /// Construct raw data of [AndMultipleVersionConstraint] with given [List]
  /// of [VersionConstraintNode] for building a single constraint.
  AndMultipleVersionConstraint([List<VersionConstraintNode>? constraints])
      : super._(constraints);

  /// Check [version] matches all [constraints] [VersionConstraintNode].
  ///
  /// If [excludePreRelease] set `true`, the given [version] will not assume
  /// in range if no [constraints] declared with [SemVer.preRelease].
  @override
  bool inRange(SemVer version, {bool excludePreRelease = true}) =>
      _constraints.every(
          (vcs) => vcs.inRange(version, excludePreRelease: excludePreRelease));
}

/// Subtype of [MultipleVersionConstraintNode] that at least one [constraints]
/// matched.
///
/// Unlike [AndMultipleVersionConstraint], it required
/// [OrConstraintRecordSection], a mixin extended from
/// [VersionConstraintRecord] that accepted in [constraints]. Only
/// [VersionConstraintNode] and [AndMultipleVersionConstraint] can be applied.
@sealed
class OrMultipleVersionConstraint
    extends MultipleVersionConstraintNode<OrConstraintRecordSection>
    with VersionConstraintRecord {
  /// Construct raw data of [OrMultipleVersionConstraint] with given [List] of
  /// [OrConstraintRecordSection].
  OrMultipleVersionConstraint([List<OrConstraintRecordSection>? constraints])
      : super._(constraints);

  /// Check [version] matched at least one of the [OrConstraintRecordSection]
  /// in [constraints].
  ///
  /// If [excludePreRelease] set `true`, it assume be `false` when given
  /// [version] has [SemVer.preRelease] when no [constraints] has pre-release
  /// information.
  @override
  bool inRange(SemVer version, {bool excludePreRelease = true}) => _constraints
      .any((vcs) => vcs.inRange(version, excludePreRelease: excludePreRelease));
}

/// A entire object that repersenting [rawConstraint] in [VersionConstraint]
/// object.
///
/// It required applying [B] for using the top layer of
/// [MultipleVersionConstraintNode].
abstract class VersionConstraint<B extends MultipleVersionConstraintNode> {
  /// Provide a [String] of version constraint input applied from user.
  final String? rawConstraint;

  /// A container uses for this [VersionConstraint] which is an extended class
  /// from [MultipleVersionConstraintNode].
  final B constraintsContainer;

  /// Indicate empty [constraintsContainer] as accept any version.
  final bool _emptyAsAny;

  /// Construct implemented [VersionConstraint] information.
  ///
  /// Optionally, [emptyAsAny] repersent [stastified] returns `true` when
  /// applying with empty [List] in [constraintsContainer].
  @protected
  VersionConstraint(this.rawConstraint, this.constraintsContainer,
      {bool emptyAsAny = false})
      : _emptyAsAny = emptyAsAny,
        assert(emptyAsAny || constraintsContainer.constraintsItems > 0,
            "Applied empty constraint item but not empty as any.");

  /// Give a [version] that is stastified [rawConstraint] by matching data in
  /// [B].
  ///
  /// It may be always return `true` if empty [constraintsContainer] items
  /// repersents accept any [version] for some implemented [VersionConstraint].
  bool stastified(SemVer version, {bool excludePreRelease = true}) {
    if (constraintsContainer._constraints.isEmpty) return _emptyAsAny;
    return constraintsContainer.inRange(version,
        excludePreRelease: excludePreRelease);
  }
}
