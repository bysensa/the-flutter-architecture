import 'package:flutter/widgets.dart'
    show BuildContext, Action, Intent, ActionListenerCallback;
import 'package:mobx/mobx.dart' hide Action;

mixin ActionMixin<T extends Intent> on Action<T> {
  @override
  bool isEnabled(Intent intent, [BuildContext? context]) {
    return _isActionEnabled;
  }

  @override
  bool consumesKey(Intent intent) {
    return _isActionEnabled;
  }

  bool Function()? get isActionEnabledPredicate;

  /// Internal variable for [isActionEnabled] value
  ///
  /// Value is updated using reaction when [isActionEnabledPredicate] is evaluated and action has listeners
  bool _isActionEnabled = true;

  /// Number of listeners for this action
  ///
  /// Value is incremented when listener is added and decremented when listener is removed
  int _listenersCount = 0;

  /// Disposer for isActionEnabled reaction
  ///
  /// Instance is created when first listener is added
  /// After last listener is removed, reaction is disposed
  Dispose? _isEnabledEffectDispose;

  /// Sets up reaction for [isActionEnabled] value
  ///
  /// Reaction is set up when first listener is added
  void _maybeSetUpIsEnabledReaction() {
    if (_listenersCount > 0 && _isEnabledEffectDispose == null) {
      _isEnabledEffectDispose = reaction(
        (_) => isActionEnabledPredicate?.call() ?? true,
        (value) {
          _isActionEnabled = value;
          notifyActionListeners();
        },
        fireImmediately: true,
      ).call;
    }
  }

  /// Tears down reaction for [isActionEnabled] value
  ///
  /// Reaction is disposed when last listener is removed
  void _maybeTearDownIsEnabledReaction() {
    if (_listenersCount == 0 && _isEnabledEffectDispose != null) {
      _isEnabledEffectDispose?.call();
      _isEnabledEffectDispose = null;
    }
  }

  /// Adds listener to this action
  ///
  /// Method overrided to support MobX reactions setup for isActionEnabled and isConsumesKey
  /// When first listener is added, reactions is set up
  @override
  void addActionListener(ActionListenerCallback listener) {
    super.addActionListener(listener);
    _listenersCount++;
    _maybeSetUpIsEnabledReaction();
  }

  /// Removes listener from this action
  ///
  /// Method overrided to support MobX reactions teardown for isActionEnabled and isConsumesKey
  /// When last listener is removed, reaction is disposed
  @override
  void removeActionListener(ActionListenerCallback listener) {
    super.removeActionListener(listener);
    _listenersCount--;
    _maybeTearDownIsEnabledReaction();
  }
}
