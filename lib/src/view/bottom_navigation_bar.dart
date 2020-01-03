import 'package:flutter/material.dart';

/// Bottom navigation bar of time trakr application. Used to navigate between
/// different views of the application.
class TimeTrakrBottomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onCurrentViewChange;
  final int currentIndex;

  /// Create bottom navigation bar, pointing to view with [currentIndex]
  /// by default.
  /// [onCurrentViewChange] gets called when user chooses different view
  /// in this navigation bar.
  TimeTrakrBottomNavigationBar({
    this.onCurrentViewChange,
    this.currentIndex = 0
  });

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
