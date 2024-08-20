import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:nested/nested.dart';

/// An inherited widget for a [ObservableValue] [observable], which updates its
/// dependencies when the [observable] is triggered.
///
/// This is a variant of [InheritedWidget], specialized for subclasses of
/// [ObservableValue], such as [ChangeNotifier] or [ValueNotifier].
///
/// Dependents are notified whenever the [notifier] sends notifications, or
/// whenever the identity of the [notifier] changes.
///
/// Multiple notifications are coalesced, so that dependents only rebuild once
/// even if the [notifier] fires multiple times between two frames.
///
/// Typically this class is subclassed with a class that provides an `of` static
/// method that calls [BuildContext.dependOnInheritedWidgetOfExactType] with that
/// class.
///
/// The [updateShouldNotify] method may also be overridden, to change the logic
/// in the cases where [notifier] itself is changed. The [updateShouldNotify]
/// method is called with the old [notifier] in the case of the [notifier] being
/// changed. When it returns true, the dependents are marked as needing to be
/// rebuilt this frame.
///
/// This example shows three spinning squares that use the value of the notifier
/// on an ancestor [InheritedNotifier] (`SpinModel`) to give them their
/// rotation. The [InheritedNotifier] doesn't need to know about the children,
/// and the `notifier` argument doesn't need to be an animation controller, it
/// can be anything that implements [ObservableValue] (like a [ChangeNotifier]).
///
/// The `SpinModel` class could just as easily listen to another object (say, a
/// separate object that keeps the value of an input or data model value) that
/// is a [ObservableValue], and get the value from that. The descendants also don't
/// need to have an instance of the [InheritedNotifier] in order to use it, they
/// just need to know that there is one in their ancestry. This can help with
/// decoupling widgets from their models.
abstract class InheritedObservable<T> extends InheritedWidget
    implements SingleChildWidget {
  /// Create an inherited widget that updates its dependents when [notifier]
  /// sends notifications.
  const InheritedObservable({
    super.key,
    required ObservableValue<T> observable,
    super.child = const SizedBox.shrink(),
    String? debugName,
    ReactiveContext? reactiveContext,
  })  : _observable = observable,
        _debugName = debugName,
        _reactiveContext = reactiveContext;

  static InheritedObservableGroup group(
    List<InheritedObservable> group, {
    required Widget child,
    Key? key,
  }) {
    return InheritedObservableGroup(
      group: group,
      key: key,
      child: child,
    );
  }

  static T read<T extends InheritedObservable>(BuildContext context) {
    final InheritedElement? result =
        context.getElementForInheritedWidgetOfExactType<T>();
    assert(result?.widget is T, 'No $T found in context');
    return result!.widget as T;
  }

  static T? readOrNull<T extends InheritedObservable>(BuildContext context) {
    final InheritedElement? result =
        context.getElementForInheritedWidgetOfExactType<T>();
    return result?.widget as T?;
  }

  static T watch<T extends InheritedObservable>(BuildContext context) {
    final T? result = context.dependOnInheritedWidgetOfExactType<T>();
    assert(result != null, 'No $T found in context');
    return result!;
  }

  static T? watchOrNull<T extends InheritedObservable>(BuildContext context) {
    final T? result = context.dependOnInheritedWidgetOfExactType<T>();
    return result;
  }

  final String? _debugName;
  String _getDebugName() => _debugName ?? '$this';

  final ReactiveContext? _reactiveContext;
  ReactiveContext _getReactiveContext() => _reactiveContext ?? mainContext;

  @visibleForTesting
  ReactionDisposer createReaction(
    dynamic Function(Reaction) trackingFn, {
    Function(Object, Reaction)? onError,
  }) =>
      autorun(
        trackingFn,
        onError: onError,
        context: _getReactiveContext(),
        name: _getDebugName(),
      );

  /// The [ObservableValue] object to which to listen.
  ///
  /// Whenever this object sends change notifications, the dependents of this
  /// widget are triggered.
  ///
  /// By default, whenever the [notifier] is changed (including when changing to
  /// or from null), if the old notifier is not equal to the new notifier (as
  /// determined by the `==` operator), notifications are sent. This behavior
  /// can be overridden by overriding [updateShouldNotify].
  ///
  /// While the [notifier] is null, no notifications are sent, since the null
  /// object cannot itself send notifications.
  final ObservableValue<T> _observable;

  T get value => _observable.value;
  T get valueUntracked => untracked(() => _observable.value);

  @override
  bool updateShouldNotify(covariant InheritedObservable<T> oldWidget) {
    return oldWidget._observable != _observable;
  }

  @override
  SingleChildInheritedElementMixin createElement() =>
      _InheritedObservableElement<T>(this);
}

class _InheritedObservableElement<T> extends InheritedElement
    with SingleChildWidgetElementMixin, SingleChildInheritedElementMixin {
  _InheritedObservableElement(super.widget);

  bool _dirty = false;
  ReactionDisposer? _disposer;
  InheritedObservable<T> get _widget => widget as InheritedObservable<T>;

  void _updateReaction() {
    _disposer?.call();
    _disposer = _widget.createReaction(_track, onError: (e, _) {
      FlutterError.reportError(FlutterErrorDetails(
        library: 'tfa',
        exception: e,
        stack: e is Error ? e.stackTrace : null,
        context: ErrorDescription(
          'From reaction of ${_widget._getDebugName()} of type $runtimeType.',
        ),
      ));
    });
  }

  void _track(Reaction _) => _markNeedsBuildImmediatelyOrDelayed();

  void _markNeedsBuildImmediatelyOrDelayed() async {
    // reference
    // 1. https://github.com/mobxjs/mobx.dart/issues/768
    // 2. https://stackoverflow.com/a/64702218/4619958
    // 3. https://stackoverflow.com/questions/71367080

    final _ = _widget._observable.value;

    // if there's a current frame,
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    final shouldWait =
        // surely, `idle` is ok
        schedulerPhase != SchedulerPhase.idle &&
            // By experience, it is safe to do something like
            // `SchedulerBinding.addPostFrameCallback((_) => someObservable.value = newValue)`
            // So it is safe if we are in this phase
            schedulerPhase != SchedulerPhase.postFrameCallbacks;
    if (shouldWait) {
      // uncomment to log
      // print('hi wait phase=$schedulerPhase');

      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;

      // If it is disposed after this frame, we should no longer call `markNeedsBuild`
      if (_disposer == null) return;
    }
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    _updateReaction();
    super.mount(parent, newSlot);
  }

  @override
  void update(InheritedObservable<T> newWidget) {
    final ObservableValue<T> oldObservable = _widget._observable;
    final ObservableValue<T> newObservable = newWidget._observable;
    if (oldObservable != newObservable) {
      _updateReaction();
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget as InheritedObservable<T>);
    }
    return super.build();
  }

  @override
  void notifyClients(InheritedObservable<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    _disposer?.call();
    _disposer = null;
    super.unmount();
  }
}

class InheritedObservableGroup extends StatelessWidget {
  const InheritedObservableGroup({
    super.key,
    required this.group,
    required this.child,
  });

  final List<InheritedObservable> group;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Nested(
      children: group,
      child: child,
    );
  }
}
