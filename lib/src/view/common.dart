import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final defaultDateFormat = DateFormat('HH:mm');

void showError(BuildContext buildContext, Object error) {
  Scaffold.of(buildContext).showSnackBar(SnackBar(content: Text(error.toString()), duration: Duration(seconds: 3)));
}

class TimeTrakrBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onCurrentViewChange;

  TimeTrakrBottomNavigationBar({this.currentIndex = 0, this.onCurrentViewChange});

  @override
  State<StatefulWidget> createState() {
    return TimeTrakrBottomNavigationBarState(currentIndex);
  }
}

class TimeTrakrBottomNavigationBarState extends State<TimeTrakrBottomNavigationBar> {
  int currentIndex;

  TimeTrakrBottomNavigationBarState(this.currentIndex);

  void setCurrentIndex(int index) {
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
        onTap: setCurrentIndex,
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