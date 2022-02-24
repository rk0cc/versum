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

extension _VersionConstraintOperator on VersionConstraintOperator {
  bool matched(SemVer constraint, SemVer provided) {
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

mixin VersionConstraintRecord {
  bool inRange(SemVer version);
}

mixin OrConstraintRecordSection on VersionConstraintRecord {}

@sealed
class VersionConstraintNode
    with VersionConstraintRecord, OrConstraintRecordSection {
  final SemVer affectedVersion;
  final VersionConstraintOperator constraintOperator;

  VersionConstraintNode._(this.affectedVersion, this.constraintOperator);

  factory VersionConstraintNode(
          {required SemVer affectedVersion,
          required VersionConstraintOperator constraintOperator}) =>
      VersionConstraintNode._(affectedVersion, constraintOperator);

  bool inRange(SemVer version) =>
      constraintOperator.matched(affectedVersion, version);

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
  bool inRange(SemVer version) =>
      _constraints.every((vcs) => vcs.inRange(version));
}

@sealed
class OrMultipleVersionConstraint
    extends MultipleVersionConstraintNode<OrConstraintRecordSection>
    with VersionConstraintRecord {
  @protected
  OrMultipleVersionConstraint([List<OrConstraintRecordSection>? constraints])
      : super._(constraints);

  @override
  bool inRange(SemVer version) =>
      _constraints.any((vcs) => vcs.inRange(version));
}

abstract class VersionConstraint<B extends MultipleVersionConstraintNode> {
  final String? rawConstraint;
  final B constraintsContainer;

  @protected
  VersionConstraint(this.rawConstraint, this.constraintsContainer);

  bool stastified(SemVer version) => constraintsContainer.inRange(version);
}
