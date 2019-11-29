import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';

import '../../model.dart';
import '../../query.dart';
import '../common.dart';
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

  StartedActivitiesView(this.boundedContext, this.projectionFactory, {StartedActivitiesViewController controller}):
        this.controller = controller ?? StartedActivitiesViewController();

  @override
  State<StatefulWidget> createState() {
    return StartedActivitiesViewState();
  }
}

class StartedActivitiesViewState extends State<StartedActivitiesView> {
  Projection<Specification, List<StartedActivity>> todaysActivitiesProjection;

  Future<void> handleActivityStart(String name, DateTime startDate, BuildContext context) async {
    try {
      await widget.boundedContext.startNewActivity(name, startDate);
    } catch (e) {
      showError(context, e);
    }
  }

  Future<void> handleActivityDelete(StartedActivity startedActivity, BuildContext context) async {
    try {
      await widget.boundedContext.removeActivity(startedActivity);
    } catch (e) {
      showError(context, e);
    }
  }

  void handleActivityStartRequest(BuildContext context, {String activityName}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (bottomSheetContext) => StartActivityBottomSheetDialog(
          onStartActivity: (String name, DateTime startDate) => handleActivityStart(name, startDate, context),
          bottomSheetContext: bottomSheetContext,
          activityName: activityName,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StartedActivitiesListView(
        startedActivitiesStream: todaysActivitiesProjection.stream,
        onProlong: (activity) => handleActivityStartRequest(context, activityName: activity.name),
        onDelete: (activity) => handleActivityDelete(activity, context)
    );
  }

  @override
  void initState() {
    super.initState();
    todaysActivitiesProjection = widget.projectionFactory.findActivitiesStartedToday();
    widget.controller.onRequestNewActivityStart = handleActivityStartRequest;
  }

  @override
  void dispose() {
    super.dispose();
    todaysActivitiesProjection.stop();
  }
}