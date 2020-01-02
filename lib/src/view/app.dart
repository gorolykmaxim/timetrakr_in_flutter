import 'package:clock/clock.dart';
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
  final DurationFormat durationFormat = DurationFormat.hoursAndMinutes();
  final Clock clock;

  TimeTrakrApp({@required this.boundedContext, @required this.projectionFactory, @required this.clock});

  @override
  State<StatefulWidget> createState() {
    return TimeTrakrAppState();
  }
}

class TimeTrakrAppState extends State<TimeTrakrApp> {
  int currentViewIndex = 0;
  List<Widget> views;
  final StartedActivitiesViewController controller = StartedActivitiesViewController();

  void initialize(TimeTrakrApp widget) {
    views = [
      StartedActivitiesView(
        boundedContext: widget.boundedContext,
        projectionFactory: widget.projectionFactory,
        clock: widget.clock,
        controller: controller,
        dateFormat: widget.dateFormat,
      ),
      ActivitiesReportView(
        projectionFactory: widget.projectionFactory,
        durationFormat: widget.durationFormat,
        clock: widget.clock,
      )
    ];
  }

  void changeCurrentView(State state, int newViewIndex) {
    state.setState(() {
      currentViewIndex = newViewIndex;
    });
  }

  @override
  void initState() {
    initialize(widget);
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
          onCurrentViewChange: (i) => changeCurrentView(this, i),
        ),
      ),
    );
  }
}