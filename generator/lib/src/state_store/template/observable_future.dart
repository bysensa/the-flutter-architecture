import 'annotations_generator_mixin.dart';
import 'method_override.dart';

import 'store.dart';

class ObservableFutureTemplate with AnnotationsGenerator {
  ObservableFutureTemplate({
    required this.method,
    required this.storeTemplate,
    required bool hasProtected,
    required bool hasVisibleForOverriding,
    required bool hasVisibleForTesting,
  }) {
    this.hasProtected = hasProtected;
    this.hasVisibleForOverriding = hasVisibleForOverriding;
    this.hasVisibleForTesting = hasVisibleForTesting;
  }

  final MethodOverrideTemplate method;
  final StoreTemplate storeTemplate;

  @override
  String toString() => """
  $annotations
  ObservableFuture${method.returnTypeArgs} ${method.name}${method.typeParams}(${method.params}) {
    final _\$future = super.${method.name}${method.typeArgs}(${method.args});
    return ObservableFuture${method.returnTypeArgs}(_\$future, context: ${storeTemplate.contextName});
  }""";
}
