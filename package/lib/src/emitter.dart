import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class EventEmitter<T extends Object> extends InheritedWidget {
  const EventEmitter(
    this._eventStream, {
    super.key,
    required super.child,
  });

  final Stream<T> _eventStream;

  @override
  InheritedElement createElement() => EventEmitterElement<T>(this);

  @override
  bool updateShouldNotify(EventEmitter<T> oldWidget) =>
      oldWidget._eventStream != _eventStream;
}

class EventEmitterElement<T extends Object> extends InheritedElement {
  EventEmitterElement(EventEmitter<T> super.widget);

  EventEmitter<T> get _widget => widget as EventEmitter<T>;

  StreamSubscription<T>? _subscription;
  final HashedObserverList<EventListenerMixin<T, StatefulWidget>> _listeners =
      HashedObserverList();

  EventListenerMixin<T, StatefulWidget>? _maybeEventListener(
    Element dependent,
  ) {
    if (dependent is StatefulElement &&
        dependent.state is EventListenerMixin<T, StatefulWidget>) {
      return dependent.state as EventListenerMixin<T, StatefulWidget>;
    }
    return null;
  }

  void _handleEvent(T event) async {
    for (final listener in _listeners) {
      listener.call(event);
    }
  }

  void _updateSubscription() {
    _subscription?.cancel();
    _subscription = _widget._eventStream.listen(
      _handleEvent,
      cancelOnError: false,
    );
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    _updateSubscription();
    super.mount(parent, newSlot);
  }

  void _clearListeners() {
    final listeners = [..._listeners];
    for (final listener in listeners) {
      _listeners.remove(listener);
    }
  }

  @override
  void unmount() {
    _subscription?.cancel();
    _subscription = null;
    _clearListeners();
    super.unmount();
  }

  @override
  void update(EventEmitter<T> newWidget) {
    final Stream<T> oldObservable = _widget._eventStream;
    final Stream<T> newObservable = newWidget._eventStream;
    if (oldObservable != newObservable) {
      _updateSubscription();
    }
    super.update(newWidget);
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final listener = _maybeEventListener(dependent);
    if (listener == null) {
      super.updateDependencies(dependent, aspect);
    } else {
      _listeners.add(listener);
    }
  }

  @override
  void removeDependent(Element dependent) {
    super.removeDependent(dependent);
    final listener = _maybeEventListener(dependent);
    if (listener != null) {
      _listeners.remove(listener);
    }
  }
}

mixin EventListenerMixin<T extends Object, W extends StatefulWidget>
    on State<W> {
  final Map<Type, _EventProcessor> _valueSetters = {};

  void register<S>(ValueSetter<S> setter) {
    if (_valueSetters.isEmpty) {}
    _valueSetters[S] = _EventProcessor<S>(valueSetter: setter);
  }

  void unregister<S>() {
    _valueSetters.remove(S);
  }

  bool _canHandleEvent(Type eventType) {
    return _valueSetters.containsKey(eventType);
  }

  void call(Object event) {
    if (_canHandleEvent(event.runtimeType)) {
      _valueSetters[event.runtimeType]?.call(event);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final element =
        context.getElementForInheritedWidgetOfExactType<EventEmitter<T>>();
    if (element == null) {
      return;
    }
    context.dependOnInheritedElement(element);
  }

  @override
  void dispose() {
    _valueSetters.clear();
    super.dispose();
  }
}

class _EventProcessor<T> {
  final ValueSetter<T> _valueSetter;

  const _EventProcessor({
    required ValueSetter<T> valueSetter,
  }) : _valueSetter = valueSetter;

  void call(Object event) {
    if (event is T) {
      _valueSetter(event as T);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EventProcessor &&
          runtimeType == other.runtimeType &&
          _valueSetter == other._valueSetter;

  @override
  int get hashCode => _valueSetter.hashCode;
}
