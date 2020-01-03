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

/// Root time trakr widget. Displays entire application.
class TimeTrakrApp extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ApplicationProjectionFactory projectionFactory;
  final DateFormat dateFormat = DateFormat("HH:mm");
  final DurationFormat durationFormat = DurationFormat.hoursAndMinutes();
  final Clock clock;

  /// Create time trakr application widget.
  /// [boundedContext] will be used to start and remove activities.
  /// [projectionFactory] will be used to creates projections to obtain
  /// lists of todays started activities and their durations.
  /// Information about current time will be obtained using [clock].
  TimeTrakrApp({
    @required this.boundedContext,
    @required this.projectionFactory,
    @required this.clock
  });

  @override
  State<StatefulWidget> createState() {
    return TimeTrakrAppState();
  }
}

class TimeTrakrAppState extends State<TimeTrakrApp> {
  int currentViewIndex = 0;
  List<Widget> views;
  final controller = StartedActivitiesViewController();

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