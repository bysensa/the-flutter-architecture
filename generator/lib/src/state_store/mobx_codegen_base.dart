import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build/build.dart';
import 'store_class_visitor.dart';
import 'template/store.dart';
import 'template/store_file.dart';
import '../shared/type_names.dart';
import 'package:source_gen/source_gen.dart';

class StoreGenerator extends Generator {
  final BuilderOptions options;

  StoreGenerator([this.options = BuilderOptions.empty]);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    if (library.allElements.isEmpty) {
      return '';
    }

    final typeSystem = library.element.typeSystem;
    final file = StoreFileTemplate(
        storeSources: _generateCodeForLibrary(library, typeSystem).toSet());
    return file.toString();
  }

  Iterable<String> _generateCodeForLibrary(
    LibraryReader library,
    TypeSystem typeSystem,
  ) sync* {
    for (final classElement in library.classes) {
      yield* _generateCodeForStateStore(library, classElement, typeSystem);
    }
  }

  Iterable<String> _generateCodeForStateStore(
    LibraryReader library,
    ClassElement baseClass,
    TypeSystem typeSystem,
  ) sync* {
    final typeNameFinder = LibraryScopedNameFinder(library.element);
    try {
      yield _generateCodeFromStateStoreTemplate(
          baseClass.name, baseClass, StateStoreTemplate(), typeNameFinder);
      // ignore: avoid_catching_errors
    } on StateError {
      // ignore the case when no element is found
    }
  }

  String _generateCodeFromStateStoreTemplate(
    String publicTypeName,
    ClassElement userStoreClass,
    StoreTemplate template,
    LibraryScopedNameFinder typeNameFinder,
  ) {
    final visitor = StoreClassVisitor(
        publicTypeName, userStoreClass, template, typeNameFinder, options);
    userStoreClass
      ..accept(visitor)
      ..visitChildren(visitor);
    return visitor.source;
  }
}
