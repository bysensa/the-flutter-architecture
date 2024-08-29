const inp = IntentParam();
const actionFn = ActionFn();

class IntentParam {
  const IntentParam();
}

class ActionFn {
  const ActionFn({this.intentType});

  final Type? intentType;
}
