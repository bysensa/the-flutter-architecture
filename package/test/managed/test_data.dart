import 'package:flutter/foundation.dart';
import 'package:tfa/managed.dart';

class Leaf {}

class Root {
  Root() : leaf = inject();

  final Leaf leaf;
}

class RootWithInjectedProp {
  Root leaf = inject();
}

class LazyRootWithInjectedProp {
  late RootWithInjectedProp root = inject();
}

class Service {
  Service() : _client = inject();

  final Client _client;
}

class Client with InitMixin {
  Client();

  void setup(String token) {}

  @override
  void init() {
    print('$this initialized');
  }
}

class Notifier with ChangeNotifier implements Listenable {}

enum NotifierType { base }
