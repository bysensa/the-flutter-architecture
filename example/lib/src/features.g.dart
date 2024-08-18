// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'features.dart';

// **************************************************************************
// ActionGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

class IncrementIntent extends Intent {
  const IncrementIntent();
}

class IncrementAction extends ContextAction<IncrementIntent> with ActionMixin {
  IncrementAction({
    required this.model,
    this.isActionEnabledPredicate,
    ReactiveContext? reactiveContext,
  }) : _reactiveContext = reactiveContext ?? mainContext;

  final CountState<StatefulWidget> model;

  @override
  final bool Function()? isActionEnabledPredicate;

  final ReactiveContext _reactiveContext;

  late final _actionController = ActionController(
    name: 'IncrementActionController',
    context: _reactiveContext,
  );

  @override
  void invoke(
    IncrementIntent intent, [
    BuildContext? context,
  ]) {
    final actionInfo =
        _actionController.startAction(name: 'IncrementAction.invoke');
    try {
      return increment(
        context!,
        model: this.model,
      );
    } finally {
      _actionController.endAction(actionInfo);
    }
  }
}

class DecrementIntent extends Intent {
  const DecrementIntent();
}

class DecrementAction extends ContextAction<DecrementIntent> with ActionMixin {
  DecrementAction({
    required this.model,
    this.isActionEnabledPredicate,
    ReactiveContext? reactiveContext,
  }) : _reactiveContext = reactiveContext ?? mainContext;

  final CountState<StatefulWidget> model;

  @override
  final bool Function()? isActionEnabledPredicate;

  final ReactiveContext _reactiveContext;

  late final _actionController = ActionController(
    name: 'DecrementActionController',
    context: _reactiveContext,
  );

  @override
  void invoke(
    DecrementIntent intent, [
    BuildContext? context,
  ]) {
    final actionInfo =
        _actionController.startAction(name: 'DecrementAction.invoke');
    try {
      return decrement(
        context!,
        model: this.model,
      );
    } finally {
      _actionController.endAction(actionInfo);
    }
  }
}
