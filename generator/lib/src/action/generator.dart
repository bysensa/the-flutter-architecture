import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build/build.dart';
import 'package:mobx/src/api/annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tfa_gen/src/action/template/action_.dart';

import '../shared/type_names.dart';
import 'template/actions.file.dart';

const _actionChecker = TypeChecker.fromRuntime(MakeAction);

class ActionGenerator extends Generator {
  final BuilderOptions options;

  ActionGenerator([this.options = BuilderOptions.empty]);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    if (library.allElements.isEmpty) {
      return '';
    }

    final typeSystem = library.element.typeSystem;
    final file = FeaturesFileTemplate(
      featureSources: _actionsSources(library, typeSystem),
    );

    return file.toString();
  }

  Iterable<String> _actionsSources(
    LibraryReader library,
    TypeSystem typeSystem,
  ) sync* {
    for (final element in library.allElements) {
      final hasFeatureAnnotation = _actionChecker.hasAnnotationOf(element);
      if (!hasFeatureAnnotation || element is! FunctionElement) {
        continue;
      }
      final typeNameFinder = LibraryScopedNameFinder(library.element);
      final template = IntentActionTemplate.fromElement(
        element,
        finder: typeNameFinder,
      );
      yield template.toString();
    }
  }
}
