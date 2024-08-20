// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

abstract class CountStateStore<W extends StatefulWidget> extends CountState<W>
    with StateStore {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Computed<String>? _$countTextComputed;
  ObservableValue<String> get countText$ => (_$countTextComputed ??=
      Computed<String>(() => super.countText, name: 'CountState.countText'));

  @override
  String get countText => countText$.value;
  Computed<int>? _$countComputed;
  ObservableValue<int> get count$ => (_$countComputed ??=
      Computed<int>(() => super.count, name: 'CountState.count'));

  @override
  int get count => count$.value;

  late final _$_countAtom =
      Atom(name: 'CountState._count', context: reactiveContext);

  @override
  int get _count {
    _$_countAtom.reportRead();
    return super._count;
  }

  @override
  set _count(int value) {
    _$_countAtom.reportWrite(value, super._count, () {
      super._count = value;
    });
  }

  late final _$CountStateActionController =
      ActionController(name: 'CountState', context: reactiveContext);

  @override
  void increment() {
    final _$actionInfo =
        _$CountStateActionController.startAction(name: 'CountState.increment');
    try {
      return super.increment();
    } finally {
      _$CountStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo =
        _$CountStateActionController.startAction(name: 'CountState.decrement');
    try {
      return super.decrement();
    } finally {
      _$CountStateActionController.endAction(_$actionInfo);
    }
  }
}
