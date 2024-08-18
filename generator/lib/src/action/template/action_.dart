import 'package:analyzer/dart/element/element.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tfa/annotations.dart' show IntentParam;
import 'package:tfa_gen/src/managed/extensions/spec.extension.dart';

import '../../shared/type_names.dart';

class IntentActionTemplate {
  IntentActionTemplate.fromElement(
    FunctionElement element, {
    required LibraryScopedNameFinder finder,
  }) {
    _intent = _IntentTemplate(
      element,
      finder: finder,
    );

    _action = _ActionTemplate(
      element,
      finder: finder,
    );
  }

  late final _IntentTemplate _intent;
  late final _ActionTemplate _action;

  @override
  String toString() => '''
$_intent
  
$_action
  ''';
}

class _IntentTemplate {
  _IntentTemplate(
    this.element, {
    required this.finder,
  });

  final FunctionElement element;
  final LibraryScopedNameFinder finder;

  late final List<ParameterElement> parameters = () {
    return element.parameters
        .where((param) => param.isIntentParameter)
        .toList();
  }();

  late Reference extendTypeRef = () {
    return TypeReference(
      (b) => b..symbol = 'Intent',
    );
  }();

  late final Constructor constructor = () {
    final builder = ConstructorBuilder();
    for (final param in parameters) {
      final constructorParameters = param.isRequiredPositional
          ? builder.requiredParameters
          : builder.optionalParameters;
      constructorParameters.add(param.constructorParameter);
    }
    builder.constant = true;
    return builder.build();
  }();

  late final List<Field> fields = () {
    return parameters.map((param) => param.toField(finder)).toList();
  }();

  late final Class cls = () {
    final builder = ClassBuilder();
    builder.name = element.intentName;
    builder.extend = extendTypeRef;
    builder.constructors.add(constructor);
    builder.fields.addAll(fields);
    return builder.build();
  }();

  @override
  String toString() {
    return cls.formattedString();
  }
}

class _ActionTemplate {
  _ActionTemplate(
    this.element, {
    required this.finder,
  });

  static final _formatter = DartFormatter();
  static final _emitter = DartEmitter(useNullSafetySyntax: true);

  final FunctionElement element;
  final LibraryScopedNameFinder finder;

  late final bool isContextAction = () {
    return element.parameters.any((param) => param.isBuildContextParameter);
  }();

  late final bool isAsyncAction = () {
    return element.returnType.isDartAsyncFuture ||
        element.returnType.isDartAsyncFuture;
  }();

  late final List<ParameterElement> parameters = () {
    return element.parameters
        .where((param) => param.isActionParameter)
        .toList();
  }();

  late final List<ParameterElement> positionalParameters = () {
    return element.parameters.where((param) => param.isPositional).toList();
  }();

  late final List<ParameterElement> namedParameters = () {
    return element.parameters.where((param) => param.isNamed).toList();
  }();

  late Reference intentTypeRef = () {
    return TypeReference((b) => b
      ..symbol = element.intentName
      ..isNullable = false);
  }();

  late Reference extendTypeRef = () {
    return TypeReference(
      (b) => b
        ..symbol = isContextAction ? 'ContextAction' : 'Action'
        ..types.add(intentTypeRef),
    );
  }();

  late Reference actionMixinRef = () {
    return refer('ActionMixin');
  }();

  late final Constructor constructor = () {
    final builder = ConstructorBuilder();
    for (final param in parameters) {
      final constructorParameters = param.isRequiredPositional
          ? builder.requiredParameters
          : builder.optionalParameters;
      constructorParameters.add(param.constructorParameter);
    }
    builder.optionalParameters.add(
      Parameter(
        (b) => b
          ..name = 'isActionEnabledPredicate'
          ..named = true
          ..toThis = true,
      ),
    );
    builder.optionalParameters.add(
      Parameter(
        (b) => b
          ..name = 'reactiveContext'
          ..named = true
          ..type = refer('ReactiveContext?'),
      ),
    );
    builder.initializers.add(refer('_reactiveContext')
        .assign(refer('reactiveContext').ifNullThen(refer('mainContext')))
        .code);
    return builder.build();
  }();

  late final List<Field> fields = () {
    return parameters.map((param) => param.toField(finder)).toList();
  }();

  late final Field isActionEnabledPredicateField = () {
    return Field(
      (b) => b
        ..name = 'isActionEnabledPredicate'
        ..type = refer('bool Function()?')
        ..annotations.add(refer('override'))
        ..modifier = FieldModifier.final$,
    );
  }();

  late final Field reactiveContextField = () {
    return Field(
      (b) => b
        ..name = '_reactiveContext'
        ..type = refer('ReactiveContext')
        ..modifier = FieldModifier.final$,
    );
  }();

  late final Field actionControllerField = () {
    final field = Field(
      (b) => b
        ..name = '_actionController'
        ..late = true
        ..modifier = FieldModifier.final$
        ..assignment = refer('ActionController').newInstance([], {
          'name': literalString('${element.actionName}Controller'),
          'context': refer('_reactiveContext'),
        }).code,
    );
    return field;
  }();

  late final Field asyncActionField = () {
    final field = Field(
      (b) => b
        ..name = '_asyncAction'
        ..late = true
        ..modifier = FieldModifier.final$
        ..assignment = refer('AsyncAction').newInstance([
          literalString('${element.actionName}.invoke')
        ], {
          'context': refer('_reactiveContext'),
        }).code,
    );
    return field;
  }();

  late final Method invokeMethod = () {
    final returnTypeRef = refer(finder.findReturnTypeName(element));
    final intentParam = Parameter(
      (b) => b
        ..name = 'intent'
        ..type = intentTypeRef,
    );

    final positionalArgs = [
      for (final param in positionalParameters) param.invocationArgument
    ];

    final namedArgs = {
      for (final param in namedParameters) param.name: param.invocationArgument
    };

    final methodImpl = isAsyncAction
        ? Block.of([
            refer('_asyncAction')
                .property('run')
                .call([
                  Method(
                    (b) => b
                      ..body = refer(element.name)
                          .call(positionalArgs, namedArgs)
                          .code,
                  ).closure,
                ])
                .returned
                .statement,
          ])
        : Block.of([
            declareFinal('actionInfo')
                .assign(
                  refer('_actionController').property('startAction').call([], {
                    'name': literalString('${element.actionName}.invoke'),
                  }),
                )
                .statement,
            const Code('try {'),
            refer(element.name)
                .call(positionalArgs, namedArgs)
                .returned
                .statement,
            const Code('} finally {'),
            refer('_actionController')
                .property('endAction')
                .call([refer('actionInfo')]).statement,
            const Code('}'),
          ]);

    final builder = MethodBuilder();
    builder
      ..name = 'invoke'
      ..returns = returnTypeRef
      ..requiredParameters.add(intentParam)
      ..annotations.add(refer('override'))
      ..body = methodImpl;
    if (isAsyncAction) {
      builder.modifier = MethodModifier.async;
    }
    if (isContextAction) {
      builder.optionalParameters.add(
        Parameter(
          (b) => b
            ..name = 'context'
            ..type = refer('BuildContext?')
            ..required = false
            ..named = false,
        ),
      );
    }
    return builder.build();
  }();

  // late final Method isActionEnabledMethod = () {
  //   final builder = MethodBuilder();
  //   builder
  //     ..name = 'isActionEnabled'
  //     ..returns = refer('bool')
  //     ..annotations.add(refer('override'))
  //     ..type = MethodType.getter
  //     ..body = Block.of([
  //       refer('isActionEnabledPredicate')
  //           .nullSafeProperty('call')
  //           .call([])
  //           .ifNullThen(literalTrue)
  //           .returned
  //           .statement,
  //     ]);
  //   return builder.build();
  // }();

  // late final Method isEnabledMethod = () {
  //   final builder = MethodBuilder();
  //   builder
  //     ..name = 'isEnabled'
  //     ..returns = refer('bool')
  //     ..annotations.add(refer('override'))
  //     ..requiredParameters.add(
  //       Parameter(
  //         (b) => b
  //           ..name = 'intent'
  //           ..type = intentTypeRef,
  //       ),
  //     )
  //     ..optionalParameters.add(
  //       Parameter(
  //         (b) => b
  //           ..name = 'context'
  //           ..type = refer('BuildContext?')
  //           ..required = false
  //           ..named = false,
  //       ),
  //     )
  //     ..body = Block.of([
  //       refer('isActionEnabled').returned.statement,
  //     ]);
  //   return builder.build();
  // }();

  late final Class cls = () {
    final builder = ClassBuilder();
    builder.name = element.actionName;
    builder.extend = extendTypeRef;
    builder.mixins.add(actionMixinRef);
    builder.constructors.add(constructor);
    builder.fields.addAll(fields);
    builder.fields.add(isActionEnabledPredicateField);
    builder.fields.add(reactiveContextField);
    if (isAsyncAction) {
      builder.fields.add(asyncActionField);
    } else {
      builder.fields.add(actionControllerField);
    }
    builder.methods.add(invokeMethod);
    // builder.methods.add(isActionEnabledMethod);
    return builder.build();
  }();

  @override
  String toString() {
    return _formatter.format('${cls.accept(_emitter)}');
  }
}

/// Extensions
extension on ParameterElement {
  static const _paramChecker = TypeChecker.fromRuntime(IntentParam);

  bool get isIntentParameter => _paramChecker.hasAnnotationOf(this);
  bool get isNotIntentParameter => !isIntentParameter;

  bool get isBuildContextParameter =>
      type.getDisplayString(withNullability: false) == 'BuildContext';
  bool get isNotBuildContextParameter => !isBuildContextParameter;

  bool get isActionParameter =>
      isNotIntentParameter && isNotBuildContextParameter;

  Code? get defaultValueDeclaration =>
      defaultValueCode != null ? Code(defaultValueCode!) : null;

  Parameter get constructorParameter => Parameter(
        (b) => b
          ..name = name
          ..named = isNamed
          ..toThis = true
          ..defaultTo = defaultValueDeclaration
          ..required = isNamed && isRequired,
      );

  Field toField(LibraryScopedNameFinder finder) => Field(
        (b) => b
          ..name = name
          ..modifier = FieldModifier.final$
          ..type = Reference(
            finder.findParameterTypeName(this),
          ),
      );

  Expression get invocationArgument {
    if (isIntentParameter) {
      return refer('intent').property(name);
    } else if (isBuildContextParameter) {
      return refer('context').nullChecked;
    } else {
      return refer('this').property(name);
    }
  }
}

extension on FunctionElement {
  String get intentName => '${name.toPascalCase()}Intent';
  String get actionName => '${name.toPascalCase()}Action';
}
