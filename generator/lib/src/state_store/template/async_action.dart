import 'annotations_generator_mixin.dart';
import 'method_override.dart';
import 'store.dart';

class AsyncActionTemplate with AnnotationsGenerator {
  AsyncActionTemplate({
    required this.storeTemplate,
    required this.isObservable,
    required this.method,
    required bool hasProtected,
    required bool hasVisibleForOverriding,
    required bool hasVisibleForTesting,
  }) {
    this.hasProtected = hasProtected;
    this.hasVisibleForOverriding = hasVisibleForOverriding;
    this.hasVisibleForTesting = hasVisibleForTesting;
  }

  final StoreTemplate storeTemplate;
  final bool isObservable;
  final MethodOverrideTemplate method;

  String get _actionField => '_\$${method.name}AsyncAction';

  String get _futureType => isObservable ? 'ObservableFuture' : 'Future';

  String get _methodCall =>
      // ignore: unnecessary_brace_in_string_interps
      '${_actionField}.run(() => super.${method.name}${method.typeArgs}(${method.args}))';

  String get _wrappedMethodCall => isObservable
      ? 'ObservableFuture${method.returnTypeArgs}($_methodCall)'
      : _methodCall;

  @override
  String toString() => """
  late final $_actionField = AsyncAction('${storeTemplate.parentTypeName}.${method.name}', context: ${storeTemplate.contextName});

  $annotations
  $_futureType${method.returnTypeArgs} ${method.name}${method.typeParams}(${method.params}) {
    return $_wrappedMethodCall;
  }""";
}
