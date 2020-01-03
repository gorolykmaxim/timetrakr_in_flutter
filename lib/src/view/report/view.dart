import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:short_stream_builder/short_stream_builder.dart';

import '../../duration.dart';
import '../../model.dart';
import '../../query.dart';
import '../animation.dart';
import 'list.dart';
import 'selected_duration.dart';

/// View that displays durations of all activities, that were started today.
/// It allows selecting and deselecting activities to display total duration
/// of all selected activities in a card, that floats up when activities get
/// selected and floats down, when activities get de-selected.
/// The view updates itself every minute to always display up-to-date durations
/// of activities on the screen.
class ActivitiesReportView extends StatefulWidget {
  final ApplicationProjectionFactory projectionFactory;
  final DurationFormat durationFormat;
  final Clock clock;

  /// Creates view, that will obtain a projection of todays activity durations
  /// report using [projectionFactory] and will display list of it's activities
  /// and their durations, while formatting the latter ones in [durationFormat].
  /// The view will use [clock] to determine current time, which will be used
  /// to determine durations of started activities.
  ActivitiesReportView({
    @required this.projectionFactory,
    @required this.clock,
    this.durationFormat
  });

  @override
  State<StatefulWidget> createState() {
    return ActivitiesReportViewState();
  }
}

class ActivitiesReportViewState extends State<ActivitiesReportView> {
  final Set<String> selectedActivities = Set();
  Timer timeRedrawingTimer;
  Projection<Specification, ActivitiesDurationReport> todaysActivitiesDurationReportProjection;

  void initialize(ActivitiesReportView widget) {
    todaysActivitiesDurationReportProjection = widget.projectionFactory.getTodaysActivitiesDurationReport();
    todaysActivitiesDurationReportProjection.stream.forEach((report) {
      selectedActivities.retainAll(report.getActivityDurations(widget.clock.now()).map((ad) => ad.activityName));
    });
    timeRedrawingTimer = Timer.periodic(Duration(minutes: 1), (_) => setState(() {}));
  }

  void destroy() {
    timeRedrawingTimer?.cancel();
    todaysActivitiesDurationReportProjection?.stop();
  }

  void handleRemoveSelection(State state) {
    state.setState(() {
      selectedActivities.clear();
    });
  }

  void handleItemClicked(State state, ActivityDuration activityDuration) {
    state.setState(() {
      if (selectedActivities.contains(activityDuration.activityName)) {
        selectedActivities.remove(activityDuration.activityName);
      } else {
        selectedActivities.add(activityDuration.activityName);
      }
    });
  }

  @override
  void initState() {
    initialize(widget);
  }

  @override
  void dispose() {
    super.dispose();
    destroy();
  }

  Widget _build(BuildContext context, AsyncSnapshot<dynamic> reportSnapshot) {
    ActivitiesDurationReport report = reportSnapshot.data;
    if (report.isEmptyAt(widget.clock.now())) {
      return _buildEmpty(context);
    } else {
      return _buildReport(context, report);
    }
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyReport();
  }

  Widget _buildReport(BuildContext context, ActivitiesDurationReport report) {
    final now = widget.clock.now();
    return Column(children: <Widget>[
      Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ActivitiesReportHeading(),
              Flexible(child: ActivityDurationList(
                activityDurations: report.getActivityDurations(now),
                selectedActivities: selectedActivities,
                durationFormat: widget.durationFormat,
                onActivityDurationClicked: (activityDuration) => handleItemClicked(this, activityDuration),
              ))
            ],
          )
      ),
      FloatUpAnimation(
          display: selectedActivities.isNotEmpty,
          child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: SelectedDuration(
                totalDuration: report.totalDurationOf(selectedActivities, now),
                durationFormat: widget.durationFormat,
                onRemoveSelection: () => handleRemoveSelection(this),
              )
          )
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.all(8),
            child: SSB(
                stream: todaysActivitiesDurationReportProjection.stream,
                buildfunction: _build
            ),
        )
    );
  }
}

/// Displays title of [ActivitiesReportView].
class ActivitiesReportHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Text(
            'Todays activities',
            style: Theme.of(context).textTheme.headline
        )
    );
  }
}

/// A placeholder, that will be displayed in [ActivitiesReportView] if there
/// are no activity durations to display.
class EmptyReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.inbox, size: 150, color: theme.disabledColor),
              Text(
                  'Here you will see how much time each of your todays activities took you',
                  style: theme.textTheme.headline.copyWith(color: theme.disabledColor),
                  textAlign: TextAlign.center
              )
            ]
        )
    );
  }
}