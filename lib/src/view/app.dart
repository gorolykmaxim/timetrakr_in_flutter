import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrakr_in_flutter/src/duration.dart';

import '../model.dart';
import '../query.dart';
import 'activity/button.dart';
import 'activity/view.dart';
import 'bottom_navigation_bar.dart';
import 'report/view.dart';

class TimeTrakrApp extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ProjectionFactory projectionFactory;
  final DateFormat dateFormat = DateFormat("HH:mm");
  final DurationFormatter durationFormatter = DurationFormatter.hoursAndMinutes();

  TimeTrakrApp(this.boundedContext, this.projectionFactory);

  @override
  State<StatefulWidget> createState() {
    return _TimeTrakrAppState();
  }
}

class _TimeTrakrAppState extends State<TimeTrakrApp> {
  int currentViewIndex = 0;
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
      ActivitiesReportView(
          projectionFactory: widget.projectionFactory,
          durationFormatter: widget.durationFormatter
      )
    ];
  }

  void _changeCurrentView(int newViewIndex) {
    setState(() {
      currentViewIndex = newViewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton;
    if (currentViewIndex == 0) {
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
        backgroundColor: Colors.grey.shade200,
        body: IndexedStack(children: views, index: currentViewIndex),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: TimeTrakrBottomNavigationBar(
          currentIndex: currentViewIndex,
          onCurrentViewChange: _changeCurrentView,
        ),
      ),
    );
  }
}