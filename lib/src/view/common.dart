import 'package:flutter/material.dart';

void showError(BuildContext buildContext, Object error) {
  Scaffold.of(buildContext).showSnackBar(SnackBar(content: Text(error.toString()), duration: Duration(seconds: 3)));
}