// import 'dart:async';
//
// import 'package:example/src/sample_state.dart';
// import 'package:flutter/widgets.dart';
// import 'package:tfa/action.dart';
// import 'package:tfa/state_store.dart';
//
// const inp = IntentParam();
//
// class IntentParam {
//   const IntentParam();
// }
//
// class SomeModel {}
//
// /// Аннотация action может использоваться вне Store или StateStore только применительно
// /// к функции. В этом случае на основе функции будет сгенерирован класс наследник класса Action и
// /// класс наследник класса Intent. Оба класса будут иметь имя соответствующее
// /// имени функции в UpperCamelCase. Параметры функции помеченные аннотацией @inp
// /// станут одноименными полями в классе наследнике Intent. Все прочие параметры за
// /// исключением параметра с типом BuildContext будут являться полями класса наследника Action.
// /// Параметр с типом BuildContext является маркером на основе которого выводиться тип базового
// /// класса Action. Если в параметрах присутствует параметр типа BuildContext тогда используется
// /// ContextAction иначе просто Action. В конструкторе наследнике Action будет два опциональных именованных
// /// параметр проверки isEnabled и isConsumesKey. В качестве значений этих параметров должны использоваться функции
// /// набор параметров которых соответствует набору полей в классе наследнике Intent.
// ///
// /// Сама функция будет вызываться в контексте вызова функции invoke в классе наследнике Action
// ///
// /// Пример ниже
// @action
// void increment(
//   BuildContext context,
//   CountState model,
//   @inp int count,
//   @inp String text,
// ) {
//   model.increment();
// }
//
// @immutable
// class IncrementIntent extends Intent {
//   final int count;
//   final String text;
//
//   const IncrementIntent({
//     required this.count,
//     required this.text,
//   });
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is IncrementIntent &&
//           runtimeType == other.runtimeType &&
//           count == other.count &&
//           text == other.text;
//
//   @override
//   int get hashCode => count.hashCode ^ text.hashCode;
// }
//
// class IncrementAction extends ContextAction<IncrementIntent> {
//   static bool _defaultConsumesKeyPredicate({
//     required int count,
//     required String text,
//   }) =>
//       true;
//
//   static bool _defaultEnabledPredicate({
//     required int count,
//     required String text,
//   }) =>
//       true;
//
//   @protected
//   final CountState model;
//
//   @protected
//   final bool Function({
//     required int count,
//     required String text,
//   }) enabledPredicate;
//
//   @protected
//   final bool Function({
//     required int count,
//     required String text,
//   }) consumesKeyPredicate;
//
//   IncrementAction(
//     this.model, {
//     this.enabledPredicate = _defaultEnabledPredicate,
//     this.consumesKeyPredicate = _defaultConsumesKeyPredicate,
//   });
//
//   @override
//   bool consumesKey(IncrementIntent intent) => consumesKeyPredicate(
//         count: intent.count,
//         text: intent.text,
//       );
//
//   static final _contextExpando = Expando<bool>();
//
//   @override
//   bool isEnabled(IncrementIntent intent, [BuildContext? context]) {
//     final isEnabled = untracked(() {
//       return enabledPredicate(
//         count: intent.count,
//         text: intent.text,
//       );
//     });
//
//     if (context is Element) {
//       final prev = _contextExpando[context];
//       _contextExpando[context] = isEnabled;
//       if (prev != null && prev != isEnabled) {
//         context.markNeedsBuild();
//       }
//     }
//     return isEnabled;
//   }
//
//   @override
//   void invoke(IncrementIntent intent, [BuildContext? context]) {
//     try {
//       return increment(
//         context!,
//         model,
//         intent.count,
//         intent.text,
//       );
//     } finally {
//       _ensureEnabledForContext(intent, context);
//     }
//   }
//
//   void _ensureEnabledForContext(IncrementIntent intent,
//       [BuildContext? context]) {}
//
//   int _listenersCount = 0;
//   VoidCallback? _effectDisposer;
//
//   @override
//   void addActionListener(ActionListenerCallback listener) {
//     try {
//       super.addActionListener(listener);
//     } catch (err, trace) {
//       Zone.current.handleUncaughtError(err, trace);
//     } finally {
//       _listenersCount++;
//       if (_listenersCount == 1) {}
//     }
//   }
//
//   @override
//   void removeActionListener(ActionListenerCallback listener) {
//     try {
//       super.removeActionListener(listener);
//     } catch (err, trace) {
//       Zone.current.handleUncaughtError(err, trace);
//     } finally {
//       _listenersCount--;
//       if (_listenersCount == 0) {}
//     }
//   }
// }
