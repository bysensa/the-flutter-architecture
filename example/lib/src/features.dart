import 'package:flutter/widgets.dart';
import 'package:tfa/action.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart' hide Action;

import 'sample_state.dart';

part 'features.g.dart';

@actionFn
void increment(BuildContext context, {required CountState model}) {
  model.increment();
}

@actionFn
void decrement(BuildContext context, {required CountState model}) {
  model.decrement();
}

@ActionFn(intentType: PrioritizedIntents)
void doWhenNothing(
  BuildContext context, {
  required CountState model,
  @inp required int? orderedIntents,
}) {
  //
}
