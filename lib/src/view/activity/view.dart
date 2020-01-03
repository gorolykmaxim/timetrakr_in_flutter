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

/// Callback called when user requests a possibility to start a new activity
/// (open new activity start dialog for instance).
typedef OnRequestNewActivityStart = void Function(BuildContext context);

/// Controller that allows users of [StartedActivitiesView] to request opening
/// of a new activity start dialog from outside.
class StartedActivitiesViewController {
  OnRequestNewActivityStart onRequestNewActivityStart = (context) {};

  /// Display new activity start dialog in [StartedActivitiesView].
  void requestNewActivityStart(BuildContext context) {
    onRequestNewActivityStart(context);
  }
}

/// View, that displays activities, the a user has started today.
/// The view allows to view all todays user's activities, starting new
/// activities, prolonging existing started activities, and removing
/// start activity events.
/// When a user will try to start a new activity by using
/// [StartedActivitiesViewController] - a bottom sheet dialog will be opened,
/// where user would have to enter information about the activity being started.
/// The same dialog will be used to prolong existing activities.
/// Existing activities can be prolonged and removed by swiping them to the left
/// or to the right correspondingly.
class StartedActivitiesView extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ApplicationProjectionFactory projectionFactory;
  final StartedActivitiesViewController controller;
  final DateFormat dateFormat;
  final Clock clock;

  /// Create view, that will display all activities, user has started today.
  /// Activities will be started and delete via [boundedContext].
  /// [projectionFactory] will be used to obtain a projection of a list
  /// of todays activities.
  /// [clock] will be used to determine current time while trying to start
  /// or prolong an activity.
  /// [dateFormat] will be used to format activity start dates, being displayed.
  /// If you want to trigger new activity start dialog externally - pass
  /// [controller] and use it to do so.
  StartedActivitiesView({
    @required this.boundedContext,
    @required this.projectionFactory,
    @required this.clock,
    DateFormat dateFormat,
    StartedActivitiesViewController controller
  }): this.controller = controller ?? StartedActivitiesViewController(),
      this.dateFormat = dateFormat ?? DateFormat();

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