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

  Computed<String>? _$countX2Computed;

  @override
  String get countX2 => (_$countX2Computed ??=
          Computed<String>(() => super.countX2, name: 'CountState.countX2'))
      .value;

  late final _$countAtom =
      Atom(name: 'CountState.count', context: reactiveContext);

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
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
