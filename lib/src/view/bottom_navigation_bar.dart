import 'package:flutter/material.dart';

class TimeTrakrBottomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onCurrentViewChange;

  TimeTrakrBottomNavigationBar({this.onCurrentViewChange});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onCurrentViewChange,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Activities')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              title: Text('Results')
          )
        ]
    );
  }
}
