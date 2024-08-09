import 'dart:async';
import 'package:tfa/managed.dart';
import 'src/service.dart';
// **************************************************************************
// ManagedGenerator
// **************************************************************************




class ManageService = Manage<Service> with ServiceProvider;


class ServiceParams extends Params {
  ServiceParams();

  @override
  Type get targetType => Service;

  @override
  void inject(
    ZoneValues values,
    Map<Type, Manage> dependencies,
  ) {}
}


mixin ServiceProvider on Manage<Service> {
  static final _provider = ManageService(
    _managed,
    scope: ScopeType.unique,
    dependsOn: [],
  );

  static Manage<Service> get provider {
    return _provider;
  }

  static Service _managed() {
    final zone = Zone.current;
    return Service();
  }

  @override
  Service call([covariant ServiceParams? params]) {
    final ZoneValues values = {};
    final deps = {for (final dep in dependencies) dep.managedType: dep};
    params?.inject(values, deps);
    values.addEntries(deps.entries.map((e) => MapEntry(e.key, e.value())));
    return runZoned(() {
      return callForGenerated();
    }, zoneValues: values);
  }
}
