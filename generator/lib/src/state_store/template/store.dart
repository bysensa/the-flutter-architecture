import 'package:analyzer/dart/element/element.dart';
import 'action.dart';
import 'async_action.dart';
import 'comma_list.dart';
import 'computed.dart';
import 'did_change_dependencies.dart';
import 'init_state.dart';
import 'observable.dart';
import 'observable_future.dart';
import 'observable_stream.dart';
import 'params.dart';
import 'provide.dart';
import 'rows.dart';

class StateStoreTemplate extends StoreTemplate {
  String get typeName => '${publicTypeName}Store';

  @override
  String get contextName => 'reactiveContext';

  @override
  bool get generateToString => false;

  @override
  String get storeBody {
    return '''
    $provides
    $initState
    $didChangeDependencies
    ${super.storeBody}
    ''';
  }

  @override
  String toString() {
    return '''
  abstract class $typeName$typeParams extends $parentTypeName$typeArgs with StateStore {
    $storeBody
  }''';
  }
}

abstract class StoreTemplate {
  final SurroundedCommaList<TypeParamTemplate> typeParams =
      SurroundedCommaList('<', '>', []);
  final SurroundedCommaList<String> typeArgs =
      SurroundedCommaList('<', '>', []);

  late String publicTypeName;
  late String parentTypeName;

  final InitStateTemplate initState = InitStateTemplate();
  final DidChangeDependenciesTemplate didChangeDependencies =
      DidChangeDependenciesTemplate();
  final Rows<ObservableTemplate> observables = Rows();
  final Rows<ProvideTemplate> provides = Rows();
  final Rows<ComputedTemplate> computeds = Rows();
  final Rows<ActionTemplate> actions = Rows();
  final Rows<AsyncActionTemplate> asyncActions = Rows();
  final Rows<ObservableFutureTemplate> observableFutures = Rows();
  final Rows<ObservableStreamTemplate> observableStreams = Rows();
  final List<String> toStringList = [];

  String get contextName;
  bool generateToString = false;
  String? _actionControllerName;
  String get actionControllerName =>
      _actionControllerName ??= '_\$${parentTypeName}ActionController';

  String get actionControllerField => actions.isEmpty
      ? ''
      : "late final $actionControllerName = ActionController(name: '$parentTypeName', context: $contextName);";

  String get toStringMethod {
    if (!generateToString) {
      return '';
    }

    final publicObservablesList = observables.templates
        .where((element) => !element.isPrivate)
        .map((current) => '${current.name}: \${${current.name}}');

    final publicComputedsList = computeds.templates
        .where((element) => !element.isPrivate)
        .map((current) => '${current.name}: \${${current.name}}');

    final allStrings = toStringList
      ..addAll(publicObservablesList)
      ..addAll(publicComputedsList);

    // The indents have been kept to ensure each field comes on a separate line without any tabs/spaces
    return '''
  @override
  String toString() {
    return \'\'\'
${allStrings.join(',\n')}
    \'\'\';
  }
  ''';
  }

  String get storeBody => '''
  $computeds

  $observables

  $observableFutures

  $observableStreams

  $asyncActions

  $actionControllerField

  $actions

  $toStringMethod
  ''';
}
