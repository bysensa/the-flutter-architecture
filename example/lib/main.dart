import 'dart:async';

import 'package:example/src/events.dart';
import 'package:example/src/features.dart';
import 'package:example/src/sample_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:tfa/state_store.dart';

final additionalContext = ReactiveContext();

final globalEmitter = StreamController<AppEvent>();

void main() {
  mainContext.config = mainContext.config.clone(
    writePolicy: ReactiveWritePolicy.always,
    isSpyEnabled: true,
  );
  mainContext.spy(print);
  runApp(
    EventEmitter(
      globalEmitter.stream,
      child: const MyApp(),
    ),
  );
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
          child: InheritedObservable.group(
            [
              Count(observable: count$),
              CountString(observable: countText$),
            ],
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

class _CountText extends StatelessWidget {
  const _CountText({super.key});

  @override
  Widget build(BuildContext context) {
    final Count count = InheritedObservable.watch(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(count.value.toString()),
    );
  }
}

class _CountStringText extends StatelessWidget {
  const _CountStringText({super.key});

  @override
  Widget build(BuildContext context) {
    final CountString? count = InheritedObservable.watchOrNull(context);
    final text = count?.value ?? 'NaN';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }
}

class Count extends InheritedObservable<int> {
  const Count({
    super.key,
    super.child,
    required super.observable,
  });
}

class CountString extends InheritedObservable<String> {
  const CountString({
    super.key,
    super.child,
    required super.observable,
  });
}
