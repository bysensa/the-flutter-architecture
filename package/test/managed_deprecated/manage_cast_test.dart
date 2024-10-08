import 'package:flutter_test/flutter_test.dart';
import 'package:tfa/managed_deprecated.dart';

class Base {}

class Child extends Base {}

class Foreign {}

void main() {
  test('can be treated', () {
    final child = Manage(
      Child.new,
      scope: ScopeType.singleton,
    );

    final base = child.as<Base>();
    final childInstance = child();
    final baseInstance = base();
    expect(childInstance, baseInstance);
    child.mock(Child());
    final childMockInstance = child();
    final baseMockInstance = base();
    expect(childInstance, isNot(childMockInstance));
    expect(baseInstance, isNot(baseMockInstance));
  });

  test('can be treated', () {
    final child = Manage(
      Child.new,
      scope: ScopeType.singleton,
    );
    expect(() => child.as<Foreign>(), throwsStateError);
  });
}
