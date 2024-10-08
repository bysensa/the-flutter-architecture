import 'package:mobx/mobx.dart';

/// The `StateStore` mixin is primarily meant for code-generation and used as part of the
/// `mobx_codegen` package.
///
/// A class using this mixin is considered a MobX store for ui state and `mobx_codegen`
/// weaves the code needed to simplify the usage of MobX. It will detect annotations like
/// `@observables`, `@computed` and `@action` and generate the code needed to support these behaviors.
mixin StateStore {
  /// Override this method to use a custom context.
  ReactiveContext get reactiveContext => mainContext;
}

/// Internal class only used for code-generation with `mobx_codegen`.
class MakeProvide {
  const MakeProvide({this.listen = false});

  final bool listen;
}

const MakeProvide read = MakeProvide();
const MakeProvide watch = MakeProvide(listen: true);
