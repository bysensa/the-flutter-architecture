import 'package:example/src/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:tfa/annotations.dart';
import 'package:tfa/state_store.dart';

part 'sample_state.g.dart';

abstract class CountState<W extends StatefulWidget> extends State<W>
    with StateStore, EventListenerMixin<AppEvent, W> {
  @observable
  int _count = 0;

  @computed
  String get countText => '$_count';

  @computed
  int get count => _count;

  @override
  void initState() {
    super.initState();
    register(_onIncrementEvent);
    register(_onDecrementEvent);
    register(_onResetEvent);
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  void _onIncrementEvent(CounterIncrementedEvent event) {
    increment();
  }

  void _onDecrementEvent(CounterDecrementedEvent event) {
    decrement();
  }

  void _onResetEvent(CounterResetEvent event) {
    runInAction(() {
      _count = 0;
    });
  }
}
