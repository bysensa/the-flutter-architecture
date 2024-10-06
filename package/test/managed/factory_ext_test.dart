import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfa/managed.dart';

import 'test_data.dart';

void main() {
  test('test singleton', () {
    Container.testing();
    Leaf.new.singleton();
    Root.new.singleton();
    RootWithInjectedProp.new.singleton();
    LazyRootWithInjectedProp.new.singleton();
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
    Leaf.new.cached();
    Root.new.cached();
    RootWithInjectedProp.new.cached();
    LazyRootWithInjectedProp.new.cached();
    expect((Leaf).isRegistered, true);
    Leaf instance = inject();
    Leaf instance2 = inject();
    Root root = inject();
    RootWithInjectedProp rootProped = inject();
    LazyRootWithInjectedProp lazyRootProped = inject();
    expect(instance2, instance);
    expect(lazyRootProped.root, isNotNull);
  });

  test('test unique', () {
    Container.testing();
    Leaf.new.unique();
    Root.new.unique();
    RootWithInjectedProp.new.unique();
    LazyRootWithInjectedProp.new.unique();
    expect((Leaf).isRegistered, true);
    Leaf instance = inject();
    Leaf instance2 = inject();
    Root root = inject();
    RootWithInjectedProp rootProped = inject();
    LazyRootWithInjectedProp lazyRootProped = inject();
    expect(instance2, isNot(instance));
    expect(lazyRootProped.root, isNotNull);
  });

  test('"as"" registration test', () {
    Container.testing();
    expect(
      () => Leaf.new.unique().as<ChangeNotifier>(NotifierType.base),
      throwsStateError,
    );
    expect(
      Notifier.new
          .cached()
          .as<ChangeNotifier>(NotifierType.base)
          .as<Listenable>(NotifierType.base),
      Notifier.new,
    );

    Notifier notifier = inject();
    Listenable notifierAsListenable = inject(NotifierType.base);
    ChangeNotifier notifierAsChangeNotifier = inject(NotifierType.base);
    expect(notifier, notifierAsListenable);
    expect(notifier, notifierAsChangeNotifier);
    expect(notifierAsListenable, notifierAsChangeNotifier);
  });

  // test('test init', () async {});

  // testWidgets('', (tester) async {
  //   Container.testing();
  //   Client.new.unique();

  //   Client? client = inject();
  //   await client.initResult;
  //   expect(client.initResult.isComplete, isTrue);
  //   client = null;
  //   // await Future.delayed(Duration(minutes: 25));
  //   // await tester.runAsync<void>(() async {
  //   //   forceGC();
  //   // });
  // });
}
