import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tfa_gen/src/action/generator.dart';

import 'src/managed/builders.dart';
import 'src/state_store/mobx_codegen_base.dart';

Builder managedGenerator(BuilderOptions options) {
  return ManagedBuilder(options: options);
}

Builder moduleGenerator(BuilderOptions options) {
  return ModuleBuilder();
}

Builder stateStoreGenerator(BuilderOptions options) {
  return SharedPartBuilder(
    [StoreGenerator(options)],
    'state_store_generator',
  );
}

Builder actionGenerator(BuilderOptions options) {
  return SharedPartBuilder(
    [ActionGenerator(options)],
    'action_generator',
  );
}
