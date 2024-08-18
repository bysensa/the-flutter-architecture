import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'store.dart';
import '../../shared/non_private_name_extension.dart';

class ProvideTemplate {
  ProvideTemplate({
    required this.storeTemplate,
    required this.atomName,
    required this.type,
    required this.name,
    // this.isReadOnly = false,
    this.isPrivate = false,
    this.isLate = false,
    this.isListen = false,
  });

  final StoreTemplate storeTemplate;
  final String atomName;
  final String type;
  final String name;
  final bool isPrivate;
  final bool isReadOnly = true;
  final bool isLate;
  final bool isListen;

  /// Formats the `name` from `_foo_bar` to `foo_bar`
  /// such that the getter gets public
  @visibleForTesting
  String get getterName {
    if (isReadOnly) {
      return name.nonPrivateName;
    }
    return name;
  }

  String _buildGetters() {
    return '''
  $type get $getterName {
    $atomName.reportRead();
    return super.$name;
  }

  @override
  $type get $name => $getterName;''';
  }

  String _buildSetters() {
    if (isLate) {
      return '''
  bool _${name}IsInitialized = false;
      
  @override
  set $name($type value) {
    $atomName.reportWrite(value, _${name}IsInitialized ? super.$name : null, () {
      super.$name = value;
      _${name}IsInitialized = true;
    });
  }''';
    }

    return '''
  @override
  set $name($type value) {
    $atomName.reportWrite(value, super.$name, () {
      super.$name = value;
    });
  }''';
  }

  String _buildProvide() {
    return '''
    $type _${name}Provide({bool listen = false}) {
      if (listen) {
        return context.watch<$type>();
      } else {
        return context.read<$type>();
      }
    }
    ''';
  }

  String buildReadAssignment() {
    return '''
    $name = _${name}Provide();
    ''';
  }

  String buildWatchAssignment() {
    return '''
    $name = _${name}Provide(listen: true);
    ''';
  }

  @override
  String toString() => """
  late final $atomName = Atom(name: '${storeTemplate.parentTypeName}.$name', context: ${storeTemplate.contextName});

${_buildGetters()}

${_buildSetters()}

${_buildProvide()}
""";
}
