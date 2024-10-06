import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Type definition of factory function
typedef Factory<T> = T Function();

/// Return non nullable type from nullable type
Type nonNullableTypeOf<T>(T? object) => T;

/// Check type is nullable
bool isNullableType<T>() => null is T;

/// Return instance of type T if type T registered in Container
///
/// Parameter managementTag used for cases when we try to resolve instance
/// by its base type
T inject<T extends Object>([Enum? managementTag]) {
  return Container.nearest().resolve<T>(managementTag);
}

/// Drop mock for type T
@visibleForTesting
T? resetMock<T extends Object>() {
  return Container.nearest().resetMock<T>();
}

/// Drop all mocks
@visibleForTesting
void resetMocks() {
  Container.nearest().resetMocks();
}

/// Extension for factory functions
extension FactoryExt<T extends Object> on Factory<T> {
  /// Register factory function as singleton type T
  Factory<T> singleton() {
    final manage = Manage<T>(this, scope: ScopeType.singleton);
    _register(manage);
    return this;
  }

  /// Register factory function as cached type T
  Factory<T> cached() {
    final manage = Manage<T>(this, scope: ScopeType.cached);
    _register(manage);
    return this;
  }

  /// Register factory function as unique type T
  Factory<T> unique() {
    final manage = Manage<T>(this, scope: ScopeType.unique);
    _register(manage);
    return this;
  }

  /// Register factory function as some another type
  Factory<T> as<S extends Object>(Enum managementTag) {
    if (this is Factory<S>) {
      Container.nearest().bindTypes(S, T, managementTag);
    } else {
      throw StateError('Cant register Factory<$T> as Factory<$S>');
    }
    return this;
  }

  /// Perform factory registration in Container
  void _register(Manage<T> manage) {
    final container = Container.nearest();
    container.register(manage);
  }

  @Deprecated('Invalid implementation')
  @visibleForTesting
  S mock<S extends Object>(T mockInstance) {
    if (this is S) {
      return Container.nearest().mock<S>(this as S);
    }
    throw StateError(
      'Cant register $S as $T because $T does not conform to $S',
    );
  }
}

extension InstanceExt<T extends Object> on T {
  /// Register instance as singleton type T
  T singleton() {
    final manage = InstanceManage<T>(this, scope: ScopeType.singleton);
    _register(manage);
    return this;
  }

  /// Register instance as cached type T
  T cached() {
    final manage = InstanceManage<T>(this, scope: ScopeType.cached);
    _register(manage);
    return this;
  }

  /// Register instance as another type
  T as<S extends Object>(Enum managementTag) {
    if (this is S) {
      Container.nearest().bindTypes(S, T, managementTag);
    } else {
      throw StateError('Cant register $T as $S');
    }
    return this;
  }

  /// Perform factory registration in Container
  void _register(Manage<T> manage) {
    final container = Container.nearest();
    container.register(manage);
  }
}

/// Extension for types
extension TypeExt on Type {
  /// Check type is registered in container
  bool get isRegistered => Container.nearest().isTypeRegistered(this);

  /// drop instance of Type if it registered and exists
  void dropInstance() {
    Container.nearest().dropInstance(this);
  }

  void forget() {
    Container.nearest().forgetType(this);
  }
}

/// Module class to incapsulate registration operations
abstract class Module {
  /// Register module in global container
  Module() {
    Container.global();
    register();
  }

  /// Register module in testing container
  Module.testing() {
    Container.testing();
    register();
  }

  /// Perform registration
  void register();
}

@visibleForTesting
class Container {
  static final Expando<Container> _expando = Expando('Container');

  Container._();

  factory Container.global() {
    var container = _expando[Zone.root];
    // если глобальный контейнер есть то возвращаем его
    if (container != null) {
      return container;
    }
    // если глобального контейнера нет то создаем новый
    container = Container._();
    _expando[Zone.root] = container;
    return container;
  }

  @visibleForTesting
  factory Container.testing() {
    if (_expando[Zone.current] != null) {
      throw StateError('Container already setted up');
    }
    final container = Container._();
    _expando[Zone.current] = container;
    return container;
  }

  factory Container.nearest() {
    Container? container = _expando[Zone.root] ?? _expando[Zone.current];
    if (container != null) {
      return container;
    }

    Zone? zone = Zone.current.parent;
    while (zone != null) {
      container = _expando[zone];
      if (container != null) {
        return container;
      }
      zone = zone.parent;
    }

    throw StateError('Container is not setup');
  }

  final Scope _unique = _UniqueScope();
  final Scope _cached = _CachedScope();
  final Scope _singleton = _SingletonScope();

  final Map<Type, Object> _mocks = {};
  final Map<Type, Manage> _manageContainers = {};
  final Map<Type, ManagementRouter> _manageRoutes = {};

  bool isRegistered<T>() {
    return _manageContainers.containsKey(T);
  }

  bool isTypeRegistered(Type type) {
    return _manageContainers.containsKey(type);
  }

  void register(Manage manage) {
    final registrationType = manage.managedType;
    if (_manageContainers.containsKey(registrationType)) {
      throw StateError('Type $registrationType already registered');
    }
    _manageContainers[registrationType] = manage;
  }

  void bindTypes(Type ancestorType, Type originalType, Enum managementTag) {
    if (!isTypeRegistered(originalType)) {
      throw StateError('Type $originalType is not registered');
    }
    final router = _manageRoutes.putIfAbsent(
      ancestorType,
      () => ManagementRouter(),
    );
    router[managementTag] = originalType;
  }

  T resolve<T extends Object>([Enum? managementTag]) {
    Type registrationType = T;

    if (_mocks.containsKey(T)) {
      return _mocks[T] as T;
    }

    // try obtain specific manage container
    Manage<Object>? manage;
    // if target type is ancestor type and managementTag is provided than try to obtain type
    // related to managementTag
    if (_manageRoutes.containsKey(registrationType) && managementTag != null) {
      final router = _manageRoutes[registrationType]!;
      final typeForTag = router[managementTag];
      if (typeForTag == null) {
        throw StateError('Tag $managementTag has no associated type');
      }
      manage = _manageContainers[router[managementTag]];
    } else {
      manage = _manageContainers[registrationType];
    }
    // check that type is registered
    if (manage == null) {
      throw StateError('Type $registrationType is not registered');
    }
    // provide type using specific scope
    return switch (manage.scope) {
      ScopeType.unique => _unique.provideUsing(manage._factory),
      ScopeType.cached => _cached.provideUsing(manage._factory),
      ScopeType.singleton => _singleton.provideUsing(manage._factory),
    };
  }

  @visibleForTesting
  T mock<T extends Object>(T mockInstance) {
    _mocks[T] = mockInstance;
    return mockInstance;
  }

  @visibleForTesting
  T? resetMock<T extends Object>() {
    return _mocks.remove(T) as T?;
  }

  @visibleForTesting
  void resetMocks() {
    _mocks.clear();
  }

  void dropInstance(Type targetType) {
    if (!isTypeRegistered(targetType)) {
      throw StateError('Type $targetType is not registered');
    }
    final manage = _manageContainers[targetType]!;
    return switch (manage.scope) {
      ScopeType.unique => _unique.resetUsing(manage._factory),
      ScopeType.cached => _cached.resetUsing(manage._factory),
      ScopeType.singleton => _singleton.resetUsing(manage._factory),
    };
  }

  void forgetType(Type type) {
    _manageContainers.remove(type);
    _manageRoutes.remove(type);
    for (final router in _manageRoutes.values) {
      router.forgetType(type);
    }
  }
}

enum ScopeType {
  unique,
  cached,
  singleton,
}

/// Class used to register specific Type and instance factory for it. This class
/// must be used together with static variable. Instance of this class should be created
/// only once for concrete type [T].
class Manage<T extends Object> {
  /// scope where instances of [T] is stored
  final ScopeType scope;

  /// Factory which provide instances of type [T]
  final Factory<T> _factory;

  Manage(
    this._factory, {
    this.scope = ScopeType.unique,
  });

  Type get managedType => T;
}

class InstanceManage<T extends Object> implements Manage<T> {
  @override
  final ScopeType scope;
  @override
  final Factory<T> _factory;

  InstanceManage(
    T instance, {
    this.scope = ScopeType.unique,
  }) : _factory = (() => instance);

  @override
  Type get managedType => T;
}

/// This class used to store instances of dependencies.
///
/// There are 3 different implementation of [Scope] provided out of the box.
/// The [unique] implementation provide new instance every time. The [singleton]
/// implementation provide new instance of specific type only once. The [cached]
/// implementation provide same instance of specific type while not reset.
abstract class Scope {
  /// Returns instance created using [factory]
  ///
  /// For [unique] implementation call to this method just invoke provided [factory]
  /// and return instance created by this factory. For [singleton] implementation
  /// call to this method will check there are no instances created by this [factory].
  /// If so then new instance will be created using this [factory] and stored in internal map.
  /// Created instance will be returned. Else, previously created instance will be returned.
  /// For [cached] implementation the behaviour is similar to [singleton] implementation.
  /// The main difference is that the [cached] implementation internal map can be cleared.
  dynamic provideUsing(Factory factory);

  /// Drop previously created instances
  ///
  /// For [unique] and [singleton] implementation call of this method has no effect.
  /// For [cached] implementation its trigger drop of previously created instances.
  void reset();

  /// Drop instance related to specific factory
  void resetUsing(Factory factory);
}

class _UniqueScope implements Scope {
  @override
  dynamic provideUsing(Factory factory) {
    final instance = factory();
    try {
      if (instance is InitMixin) {
        instance.init();
      }
    } catch (err, trace) {
      Zone.current.handleUncaughtError(err, trace);
    }
    return instance;
  }

  @override
  void reset() {}

  @override
  void resetUsing(Factory factory) {}
}

class _SingletonScope implements Scope {
  final Map<Factory, Object> _instances = {};

  @override
  dynamic provideUsing(Factory factory) {
    if (_instances.containsKey(factory)) {
      return _instances[factory];
    }
    final instance = factory();
    _instances[factory] = instance;
    try {
      if (instance is InitMixin) {
        instance.init();
      }
    } catch (err, trace) {
      Zone.current.handleUncaughtError(err, trace);
    }
    return instance;
  }

  @override
  void reset() {}

  @override
  void resetUsing(Factory factory) {}
}

class _CachedScope implements Scope {
  final Map<Factory, Object> _instances = {};

  @override
  dynamic provideUsing(Factory factory) {
    if (_instances.containsKey(factory)) {
      return _instances[factory];
    }
    final instance = factory();
    _instances[factory] = instance;
    try {
      if (instance is InitMixin) {
        instance.init();
      }
    } catch (err, trace) {
      Zone.current.handleUncaughtError(err, trace);
    }
    return instance;
  }

  @override
  void reset() {
    _instances.clear();
  }

  @override
  void resetUsing(Factory factory) {
    _instances.remove(factory);
  }
}

// Store relation between types
class ManagementRouter {
  final Map<Enum, Type> _routes = {};

  Type? operator [](Enum? key) {
    return _routes[key];
  }

  void operator []=(Enum key, Type value) {
    _routes[key] = value;
  }

  void forgetType(Type type) {
    _routes.removeWhere((e, t) => t == type);
  }
}

mixin InitMixin {
  FutureOr<void> init();
}
