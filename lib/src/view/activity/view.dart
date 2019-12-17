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

  StartedActivitiesView(this.boundedContext, this.projectionFactory, {this.dateFormat, StartedActivitiesViewController controller}):
        this.controller = controller ?? StartedActivitiesViewController();

  @override
  State<StatefulWidget> createState() {
    return _StartedActivitiesViewState();
  }
}

class _StartedActivitiesViewState extends State<StartedActivitiesView> {
  Projection<Specification, List<StartedActivity>> todaysActivitiesProjection;

  Future<void> _handleActivityStart(String name, DateTime startDate, BuildContext context) async {
    try {
      await widget.boundedContext.startNewActivity(name, startDate);
    } on ActivityStartException catch (e) {
      Scaffold.of(context).showSnackBar(ErrorSnackBar(error: e.format(widget.dateFormat)));
    }
  }

  Future<void> _handleActivityDelete(StartedActivity startedActivity, BuildContext context) async {
    try {
      await widget.boundedContext.removeActivity(startedActivity);
    } on ActivityStartException catch (e) {
      Scaffold.of(context).showSnackBar(ErrorSnackBar(error: e.format(widget.dateFormat)));
    }
  }

  void _handleActivityStartRequest(BuildContext context, {String activityName}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (bottomSheetContext) => StartActivityBottomSheetDialog(
          onStartActivity: (String name, DateTime startDate) => _handleActivityStart(name, startDate, context),
          bottomSheetContext: bottomSheetContext,
          activityName: activityName,
          dateFormat: widget.dateFormat,
        )
    );
  }

  @override
  void initState() {
    super.initState();
    todaysActivitiesProjection = widget.projectionFactory.findActivitiesStartedToday();
    widget.controller.onRequestNewActivityStart = _handleActivityStartRequest;
  }

  @override
  void dispose() {
    super.dispose();
    todaysActivitiesProjection.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: StartedActivitiesListView(
          startedActivitiesStream: todaysActivitiesProjection.stream,
          onProlong: (activity) => _handleActivityStartRequest(context, activityName: activity.name),
          onDelete: (activity) => _handleActivityDelete(activity, context),
          dateFormat: widget.dateFormat,
        )
    );
  }
}