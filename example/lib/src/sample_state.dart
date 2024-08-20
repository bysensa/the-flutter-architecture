import 'package:flutter/cupertino.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart';

part 'sample_state.g.dart';

abstract class CountState<W extends StatefulWidget> extends State<W>
    with StateStore {
  @observable
  int _count = 0;

  @computed
  String get countText => '$_count';

  @computed
  int get count => _count;

  @action
  void increment() {
    _count++;
  }

  @action
  void decrement() {
    _count--;
  }

  bool canIncrement({required int count, required String text}) {
    return this._count < 10;
  }
}
