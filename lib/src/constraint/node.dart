import 'dart:collection';

import 'package:meta/meta.dart' show sealed;
import 'package:quiver/core.dart';

import '../semver.dart' show SemVer;

mixin VersionConstraint<E extends Enum> {
  String? get rawConstraint;
  E get pattern;

  bool isInRange(SemVer version);
}

abstract class SingleVersionConstraint<E extends Enum>
    with VersionConstraint<E> {
  final SemVer? affectedSemVer;
  final E _pattern;
  final String? _rawConstraint;

  SingleVersionConstraint(
      {required String rawConstraint,
      required E pattern,
      required this.affectedSemVer})
      : _rawConstraint = rawConstraint,
        _pattern = pattern;

  @override
  E get pattern => _pattern;

  @override
  String? get rawConstraint => _rawConstraint;

  @override
  int get hashCode => hash3(affectedSemVer, _pattern, _rawConstraint);
}

enum MultipleVersionConstraintChainOption { and, or }

abstract class MultipleVersionConstraint<E extends Enum>
    extends SetBase<VersionConstraint<E>> with VersionConstraint<E> {
  final Set<VersionConstraint<E>> _constraints = {};
  final E _pattern;
  final MultipleVersionConstraintChainOption chainOption;

  MultipleVersionConstraint({required this.chainOption, required E pattern})
      : _pattern = pattern;

  @override
  bool isInRange(SemVer version) {
    switch (chainOption) {
      case MultipleVersionConstraintChainOption.and:
        // Every constraint has matched
        return _constraints.every((vc) => vc.isInRange(version));
      case MultipleVersionConstraintChainOption.or:
        // Either constraint has matched
        return _constraints.any((vc) => vc.isInRange(version));
      default:
        // Throw exception when the chain option is undefined
        throw UnsupportedError(
            "${chainOption} is undefined chain version constraint option");
    }
  }

  @override
  E get pattern => _pattern;

  @override
  bool add(VersionConstraint<E> value) {
    assert(value.rawConstraint != null,
        "Null raw constraint can not uses in multiple constraint");
    return _constraints.add(value);
  }

  @override
  bool contains(Object? element) => element is String
      ? _constraints.any((vc) => vc.rawConstraint == element)
      : _constraints.contains(element);

  @override
  Iterator<VersionConstraint<E>> get iterator => _constraints.iterator;

  @override
  int get length => _constraints.length;

  @override
  VersionConstraint<E>? lookup(Object? element) => _constraints.lookup(element);
  @override
  bool remove(Object? value) {
    if (value is String) {
      int originLength = _constraints.length;
      try {
        _constraints.removeWhere((vc) => vc.rawConstraint == value);
        return originLength > _constraints.length;
      } catch (_e) {
        return false;
      }
    } else
      return _constraints.remove(value);
  }

  @override
  Set<VersionConstraint<E>> toSet() => Set.from(_constraints);
}
