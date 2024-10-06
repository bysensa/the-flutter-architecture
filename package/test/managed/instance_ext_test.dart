import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfa/managed.dart';

import 'test_data.dart';

void main() {
  test('test singleton', () {
    Container.testing();
    Leaf().singleton();
    Root().singleton();
    RootWithInjectedProp().singleton();
    LazyRootWithInjectedProp().singleton();
    expect((Leaf).isRegistered, true);
    Leaf instance = inject();
    Leaf instance2 = inject();
    Root root = inject();
    RootWithInjectedProp rootProped = inject();
    LazyRootWithInjectedProp lazyRootProped = inject();
    expect(instance2, instance);
    expect(lazyRootProped.root, isNotNull);
  });
  test('test cached', () {
    Container.testing();
    Leaf().cached();
    Root().cached();
    RootWithInjectedProp().cached();
    LazyRootWithInjectedProp().cached();
    expect((Leaf).isRegistered, true);
    Leaf instance = inject();
    Leaf instance2 = inject();
    Root root = inject();
    RootWithInjectedProp rootProped = inject();
    LazyRootWithInjectedProp lazyRootProped = inject();
    expect(instance2, instance);
    expect(lazyRootProped.root, isNotNull);
  });

  test('"as"" registration test', () {
    Container.testing();
    expect(
      () => Leaf().cached().as<ChangeNotifier>(NotifierType.base),
      throwsStateError,
    );
    expect(
      Notifier()
          .cached()
          .as<ChangeNotifier>(NotifierType.base)
          .as<Listenable>(NotifierType.base),
      isA<Notifier>(),
    );

    Notifier notifier = inject();
    Listenable notifierAsListenable = inject(NotifierType.base);
    ChangeNotifier notifierAsChangeNotifier = inject(NotifierType.base);
    expect(notifier, notifierAsListenable);
    expect(notifier, notifierAsChangeNotifier);
    expect(notifierAsListenable, notifierAsChangeNotifier);
  });
}
