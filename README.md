# Customizable version constraint policy
[![badge](https://img.shields.io/pub/v/versum?include_prereleases&style=flat-square)](https://pub.dev/packages/versum)

Versum allows to custom define version constraint policy depending package manager.

## Usage

**Parse version**

* Constructor
    ```dart
    SemVer constructor = SemVer(major: 1);
    ```
* Parse from String
    ```dart
    SemVer parse = SemVer.parse("1.0.0");
    ```

**Version constraint**

P.S. Different package has different implementation.

```dart
VersionConstraint constraint = DummyVersionConstraint(">=1.0.0 <2.0.0");

bool isInRange = constraint.stastified(SemVer.parse("1.2.0"));
```

## License

BSD-3