import 'package:flutter/cupertino.dart';
import 'package:tfa/state_store.dart';

part 'sample_state.g.dart';

abstract class CountState<W extends StatefulWidget> extends State<W>
    with StateStore {
  @observable
  int count = 0;

  @computed
  String get countX2 => '$count';

  @action
  void increment() {
    count++;
  }

  @action
  void decrement() {
    count--;
  }

  bool canIncrement({required int count, required String text}) {
    return this.count < 10;
  }
}
