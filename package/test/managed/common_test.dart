import 'package:flutter_test/flutter_test.dart';
import 'package:tfa/managed.dart';

import 'test_data.dart';

void main() {
  test('test isNullableType', () {
    expect(isNullableType<int?>(), true);
    expect(isNullableType<int>(), false);
  });

  test('', () {
    Function.apply(Leaf.new, [], {});
  });

  test('init covariance check', () {
    final client = Client();
    expect(client, isA<InitMixin>());
  });
}
