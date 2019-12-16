import 'package:flutter/material.dart';

class TimeTrakrBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onCurrentViewChange;

  TimeTrakrBottomNavigationBar({this.currentIndex = 0, this.onCurrentViewChange});

  @override
  State<StatefulWidget> createState() {
    return _TimeTrakrBottomNavigationBarState(currentIndex);
  }
}

class _TimeTrakrBottomNavigationBarState extends State<TimeTrakrBottomNavigationBar> {
  int currentIndex;

  _TimeTrakrBottomNavigationBarState(this.currentIndex);

  void _setCurrentIndex(int index) {
    final indexChanged = currentIndex != index;
    setState(() {
      currentIndex = index;
    });
    if (indexChanged && widget.onCurrentViewChange != null) {
      widget.onCurrentViewChange(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _setCurrentIndex,
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