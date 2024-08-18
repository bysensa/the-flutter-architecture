import 'package:example/src/do_something.dart';
import 'package:example/src/features.dart';
import 'package:example/src/sample_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:tfa/state_store.dart';

void main() {
  mainContext.config = mainContext.config.clone(
    writePolicy: ReactiveWritePolicy.always,
    isSpyEnabled: true,
  );
  mainContext.spy(print);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends CountStateStore<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      debugLabel: 'shortcuts',
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.digit1,
        ): const IncrementIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.digit2,
        ): const DecrementIntent(),
      },
      child: Actions(
        actions: {
          IncrementIntent: IncrementAction(model: this),
          DecrementIntent: DecrementAction(model: this),
        },
        child: Focus(
          autofocus: true,
          child: Count(
            stateStore: this,
            child: CountString(
              stateStore: this,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(widget.title),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _CountText(),
                      _CountStringText(),
                    ],
                  ),
                ),
                floatingActionButton:
                    const IncrementButton(), // This trailing comma makes auto-formatting nicer for build methods.
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IncrementButton extends StatelessWidget {
  const IncrementButton({super.key});

  @override
  Widget build(BuildContext context) {
    const intent = IncrementIntent();
    final handler = Actions.handler(context, intent);

    return IconButton(
      onPressed: handler,
      icon: const Icon(Icons.add),
    );
  }
}

class _CountText extends StatelessObserverWidget {
  const _CountText({super.key});

  @override
  Widget build(BuildContext context) {
    final Count count = ExposedValue.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(count.value.toString()),
    );
  }
}

class _CountStringText extends StatelessObserverWidget {
  const _CountStringText({super.key});

  @override
  Widget build(BuildContext context) {
    final CountString count = ExposedValue.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(count.value.toString()),
    );
  }
}

abstract class ExposedValue<T extends ExposedValue<dynamic, dynamic, dynamic>,
    S extends StateStore, V> extends InheritedWidget {
  const ExposedValue({
    super.key,
    required super.child,
    required this.stateStore,
  });

  Type get type => T;

  final S stateStore;

  V get value;

  static T of<T extends ExposedValue>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<T>()!;
  }

  @override
  bool updateShouldNotify(ExposedValue oldWidget) {
    return false;
  }
}

class Count extends ExposedValue<Count, CountStateStore, int> {
  const Count({
    super.key,
    required super.child,
    required super.stateStore,
  });

  @override
  int get value => stateStore.count;
}

class CountString extends ExposedValue<CountString, CountStateStore, String> {
  const CountString({
    super.key,
    required super.child,
    required super.stateStore,
  });

  @override
  String get value => stateStore.countX2;
}

// class MyInherited extends InheritedWidget implements SingleChildWidget {
//   const MyInherited({super.key, this.height, required super.child});
//
//   final double? height;
//
//   @override
//   MyInheritedElement createElement() => MyInheritedElement(this);
//
//   @override
//   bool updateShouldNotify(MyInherited oldWidget) {
//     return height != oldWidget.height;
//   }
// }
//
// class MyInheritedElement extends InheritedElement
//     with SingleChildWidgetElementMixin, SingleChildInheritedElementMixin {
//   MyInheritedElement(MyInherited super.widget);
//
//   @override
//   MyInherited get widget => super.widget as MyInherited;
// }
