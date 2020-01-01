import 'package:flutter/material.dart';

class TimeTrakrBottomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onCurrentViewChange;
  final int currentIndex;

  TimeTrakrBottomNavigationBar({this.onCurrentViewChange, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onCurrentViewChange,
        currentIndex: currentIndex,
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
