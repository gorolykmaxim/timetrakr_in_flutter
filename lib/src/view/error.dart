import 'package:flutter/material.dart';

void showError(BuildContext buildContext, String error) {
  Scaffold.of(buildContext).showSnackBar(SnackBar(content: Text(error), duration: Duration(seconds: 5)));
}