import 'package:flutter/material.dart';

typedef OnActivityStartRequested = void Function(BuildContext context);

/// Floating action button, that is used to start new activity.
class StartActivityFloatingButton extends StatelessWidget {
  final OnActivityStartRequested onPressed;

  /// Create a floating button, that will call [onPressed] when a new
  /// activity should be started.
  StartActivityFloatingButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () => onPressed(context),
        tooltip: 'Start new activity',
        child: Icon(Icons.add)
    );
  }
}