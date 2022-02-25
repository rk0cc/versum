import 'package:versum/versum.dart';
import 'package:versum/build.dart';

// Construct a new version constraint object

class ExampleVersionConstraint
    extends VersionConstraint<AndMultipleVersionConstraint> {
  ExampleVersionConstraint._(
      String? rawConstraint, AndMultipleVersionConstraint constraintsContainer)
      : super(rawConstraint, constraintsContainer);

  factory ExampleVersionConstraint(String? constraints) {
    List<VersionConstraintNode> cn = [];

    // Resolving constraints to VersionConstraintNode here

    return ExampleVersionConstraint._(
        constraints, AndMultipleVersionConstraint(cn));
  }
}
