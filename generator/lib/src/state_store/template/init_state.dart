import 'provide.dart';
import 'rows.dart';

class InitStateTemplate {
  final Rows<ProvideTemplate> provides = Rows();

  void add(ProvideTemplate template) => provides.add(template);

  @override
  String toString() {
    return '''
    @override
    void initState() {
      super.initState();
      ${provides.templates.fold(StringBuffer(), (str, el) {
      return str..writeln(el.buildReadAssignment());
    })}
    }
    ''';
  }
}
