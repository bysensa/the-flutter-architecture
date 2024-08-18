library inputs;

import 'package:flutter/widgets.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart';

class Service {}

@action
List<bool> simple(
  BuildContext context,
  @inp String text, {
  @inp required bool flag,
  required Service service,
}) {
  return [false];
}
