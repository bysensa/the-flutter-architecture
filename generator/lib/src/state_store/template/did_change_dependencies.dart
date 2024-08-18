import 'provide.dart';
import '../../shared/rows.dart';

class DidChangeDependenciesTemplate {
  final Rows<ProvideTemplate> provides = Rows();

  void add(ProvideTemplate template) => provides.add(template);

  @override
  String toString() {
    return '''
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      ${provides.templates.fold(StringBuffer(), (str, el) {
      return str..writeln(el.buildWatchAssignment());
    })}
    }
    ''';
  }
}
