import 'package:tfa/state_store.dart';

sealed class AppEvent {}

class CounterResetEvent extends AppEvent {}

class CounterIncrementedEvent extends AppEvent {}

class CounterDecrementedEvent extends AppEvent {}
