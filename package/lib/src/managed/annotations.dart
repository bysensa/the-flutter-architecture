library annotations;

import 'managed.dart';

export 'managed.dart' show ScopeType;

class ManagedType {
  const ManagedType({required this.scope});

  final ScopeType scope;

  @override
  String toString() {
    return 'ManagedType{scope: $scope}';
  }
}

class Module {
  const Module();
}

/// ==============================================================================
/// Only one instance can be created. Created instance cant be replaced or dropped
class Singleton {
  const Singleton();
}

/// Provide new instance when previous is dropped
class Cached {
  const Cached();
}

/// Every time provide new instance
class Transitive {
  const Transitive();
}
