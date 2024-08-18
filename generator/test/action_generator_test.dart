import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';
import 'package:tfa_gen/src/action/template/action_.dart';
import 'package:tfa_gen/src/managed/extensions/spec.extension.dart';
import 'package:tfa_gen/src/shared/type_names.dart';

Future<LibraryElement> _library(String source, {required String name}) async {
  final lib = await resolveSources(
    {source: useAssetReader},
    (resolver) => resolver.findLibraryByName(name),
    resolverFor: source,
  );
  return lib!;
}

FunctionElement _function(LibraryElement lib, {required String name}) {
  final el = lib.topLevelElements.firstWhere((el) => el.name == name);
  return el as FunctionElement;
}

void main() {
  test('should generate', () async {
    final lib = await _library(
      'tfa_gen|test/_inputs/action.dart',
      name: 'inputs',
    );
    final opts = BuilderOptions({});
    final finder = LibraryScopedNameFinder(lib);
    final typeSystem = lib.typeSystem;
    final target = _function(lib, name: 'simple');

    print(refer('foo').call([
      literal(1)
    ], {
      'bar': literal(2),
      'baz': literal(3),
    }).formattedString);
    final template = IntentActionTemplate.fromElement(
      target,
      finder: finder,
    );
    print(template.toString());
    // final cls = lib!.getClass('Boo')!;
    // cls.visitChildren(visitor);
  });
}
