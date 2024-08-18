import 'package:flutter/widgets.dart';
import 'package:tfa/action.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart' hide Action;

import 'sample_state.dart';

part 'features.g.dart';

@action
void increment(BuildContext context, {required CountState model}) {
  model.increment();
}

@action
void decrement(BuildContext context, {required CountState model}) {
  model.decrement();
}
