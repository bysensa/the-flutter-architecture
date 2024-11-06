import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:tfa/action.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart' hide Action;

import 'events.dart';
import 'sample_state.dart';

part 'features.g.dart';

@actionFn
void increment(BuildContext context, {required CountState model}) {
  globalEmitter.add(CounterIncrementedEvent());
}

@actionFn
void decrement(BuildContext context, {required CountState model}) {
  globalEmitter.add(CounterDecrementedEvent());
}

@ActionFn(intentType: PrioritizedIntents)
void doWhenNothing(
  BuildContext context, {
  required CountState model,
  @inp required int? orderedIntents,
}) {
  //
}
