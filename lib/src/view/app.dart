import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model.dart';
import '../query.dart';
import 'activity/button.dart';
import 'activity/view.dart';
import 'bottom_navigation_bar.dart';

class TimeTrakrApp extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ProjectionFactory projectionFactory;
  final DateFormat dateFormat = DateFormat("HH:mm");

  TimeTrakrApp(this.boundedContext, this.projectionFactory);

  @override
  State<StatefulWidget> createState() {
    return TimeTrakrAppState();
  }
}

class TimeTrakrAppState extends State<TimeTrakrApp> {
  int _currentViewIndex = 0;
  List<Widget> views;
  final StartedActivitiesViewController controller = StartedActivitiesViewController();

  @override
  void initState() {
    views = [
      StartedActivitiesView(
          widget.boundedContext,
          widget.projectionFactory,
          controller: controller,
          dateFormat: widget.dateFormat,
      ),
      SizedBox.shrink()
    ];
  }

  void changeCurrentView(int newViewIndex) {
    setState(() {
      _currentViewIndex = newViewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton;
    if (_currentViewIndex == 0) {
      floatingActionButton = StartActivityFloatingButton(
        onPressed: controller.requestNewActivityStart,
      );
    }
    return MaterialApp(
      title: 'Time Trakr',
      theme: ThemeData(
          primarySwatch: Colors.green,
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.green,
              textTheme: ButtonTextTheme.primary
          )
      ),
      home: Scaffold(
        body: IndexedStack(children: views, index: _currentViewIndex),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: TimeTrakrBottomNavigationBar(
          currentIndex: _currentViewIndex,
          onCurrentViewChange: changeCurrentView,
        ),
      ),
    );
  }
}