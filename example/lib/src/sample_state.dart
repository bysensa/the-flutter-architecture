import 'package:flutter/cupertino.dart';
import 'package:tfa/state_store.dart';

part 'sample_state.g.dart';

abstract class SampleState<W extends StatefulWidget> extends State<W>
    with StateStore {}
