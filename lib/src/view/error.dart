import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({@required Object error, Duration duration}):
      super(content: Text(error), duration: duration ?? const Duration(seconds: 5));
}