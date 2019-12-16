import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({@required Object error, Duration duration = const Duration(seconds: 5)}):
      super(content: Text(error), duration: duration);
}