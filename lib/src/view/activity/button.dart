import 'package:flutter/material.dart';

typedef OnActivityStartRequested = void Function(BuildContext context);

class StartActivityFloatingButton extends StatelessWidget {
  final OnActivityStartRequested onPressed;

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