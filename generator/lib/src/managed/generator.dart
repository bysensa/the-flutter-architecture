import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:tfa/managed.dart';
import 'extensions/element.extension.dart';
import 'extensions/spec.extension.dart';
import 'imports.builder.dart';
import 'producers.dart';
import 'producers/extended.manage.producer.dart';
import 'producers/params.producer.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

class ManagedGenerator extends GeneratorForAnnotation<ManagedType> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw Exception(
        'Only class must be annotated with ManagedType annotation',
      );
    }
    final targetConstructor = element.targetConstructor;

    final moduleAsset = AssetId(
      buildStep.inputId.package,
      p.join('lib', 'module.dart'),
    );
    final importsBuilder = ImportsBuilder(moduleAsset);

    importsBuilder.add(element.library.source.uri);
    targetConstructor.parameters.forEach((parameter) {
      final typeSourceUri = parameter.type.element?.library?.source.uri;
      if (typeSourceUri == null) {
        return;
      }
      importsBuilder.add(typeSourceUri);
    });

    final extendedManage = ExtendedManageProducer(managedType: element);
    final params = ParamsProducer(managedType: element);
    final providerMixin = ProviderProducer(managedType: element);

    final buff = StringBuffer();
    buff.writeAll([
      importsBuilder.write(),
      extendedManage.produce().formattedString(),
      params.produce().formattedString(),
      providerMixin.produce().formattedString(),
    ], '\n\n');

    return buff.toString();
  }
}
