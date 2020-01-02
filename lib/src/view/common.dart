import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';

class InjectableDialogContainer {
  Future<TimeOfDay> showTimePicker({@required BuildContext context, @required TimeOfDay initialTime, TransitionBuilder builder, bool useRootNavigator = true}) {
    return material.showTimePicker(context: context, initialTime: initialTime, builder: builder, useRootNavigator: useRootNavigator);
  }
}