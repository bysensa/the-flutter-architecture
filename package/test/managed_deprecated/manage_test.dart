import 'package:flutter_test/flutter_test.dart';
import 'package:tfa/managed_deprecated.dart';

class TestClass {}

void main() {
  tearDown(() {});

  test('can add mock', () {
    final mock = TestClass();
    final manage = Manage(TestClass.new);
    manage.mock(mock);
    expect(manage.call(), mock);
  });

  test('can reset mock', () {
    final mock = TestClass();
    final manage = Manage(TestClass.new);
    manage.mock(mock);
    expect(manage.call(), mock);
    expect(manage.call(), mock);
    manage.resetMock();
    expect(manage.call(), isNot(mock));
    expect(manage.call(), isNot(mock));
  });
}
