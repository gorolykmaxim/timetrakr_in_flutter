import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:intl/intl.dart';

import '../../model.dart';
import '../../query.dart';
import '../error.dart';
import 'bottom_sheet_dialog.dart';
import 'list.dart';

typedef OnRequestNewActivityStart = void Function(BuildContext context);

class StartedActivitiesViewController {
  OnRequestNewActivityStart onRequestNewActivityStart = (context) {};

  void requestNewActivityStart(BuildContext context) {
    onRequestNewActivityStart(context);
  }
}

class StartedActivitiesView extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ProjectionFactory projectionFactory;
  final StartedActivitiesViewController controller;
  final DateFormat dateFormat;
  final Clock clock;

  StartedActivitiesView({@required this.boundedContext, @required this.projectionFactory, @required this.clock, this.dateFormat, StartedActivitiesViewController controller}):
        this.controller = controller ?? StartedActivitiesViewController();

  @override
  State<StatefulWidget> createState() {
    return StartedActivitiesViewState();
  }
}

class StartedActivitiesViewState extends State<StartedActivitiesView> {
  Projection<Specification, List<StartedActivity>> todaysActivitiesProjection;

  void initialize(StartedActivitiesView widget) {
    todaysActivitiesProjection = widget.projectionFactory.findActivitiesStartedToday();
    widget.controller.onRequestNewActivityStart = _handleActivityStartRequest;
  }

  void destroy() {
    todaysActivitiesProjection.stop();
  }

  Future<void> handleActivityStart(StartedActivitiesView widget, String name, DateTime startDate, ScaffoldState scaffoldState) async {
    try {
      await widget.boundedContext.startNewActivity(name, startDate);
    } on ActivityStartException catch (e) {
      scaffoldState.showSnackBar(ErrorSnackBar(error: e.format(widget.dateFormat)));
    }
  }

  Future<void> handleActivityDelete(StartedActivitiesView widget, StartedActivity startedActivity, ScaffoldState scaffoldState) async {
    try {
      await widget.boundedContext.removeActivity(startedActivity);
    } on ActivityStartException catch (e) {
      scaffoldState.showSnackBar(ErrorSnackBar(error: e.format(widget.dateFormat)));
    }
  }

  void _handleActivityStartRequest(BuildContext context, {String activityName}) {
    final scaffoldState = Scaffold.of(context);
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (bottomSheetContext) => StartActivityBottomSheetDialog(
          onStartActivity: (String name, DateTime startDate) => handleActivityStart(widget, name, startDate, scaffoldState),
          bottomSheetContext: bottomSheetContext,
          activityName: activityName,
          dateFormat: widget.dateFormat,
          startDate: widget.clock.now(),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    initialize(widget);
  }

  @override
  void dispose() {
    super.dispose();
    destroy();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    return SafeArea(
        child: StartedActivitiesListView(
          startedActivitiesStream: todaysActivitiesProjection.stream,
          onProlong: (activity) => _handleActivityStartRequest(context, activityName: activity.name),
          onDelete: (activity) => handleActivityDelete(widget, activity, scaffoldState),
          dateFormat: widget.dateFormat,
        )
    );
  }
}