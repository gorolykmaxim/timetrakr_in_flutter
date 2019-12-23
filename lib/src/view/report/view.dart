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

class ActivitiesReportView extends StatefulWidget {
  final ProjectionFactory projectionFactory;
  final DurationFormatter durationFormatter;
  final Clock clock;

  ActivitiesReportView({@required this.projectionFactory, @required this.clock, this.durationFormatter});

  @override
  State<StatefulWidget> createState() {
    return _ActivitiesReportViewState();
  }
}

class _ActivitiesReportViewState extends State<ActivitiesReportView> {
  final Set<String> selectedActivities = Set();
  Timer timeRedrawingTimer;
  Projection<Specification, ActivitiesDurationReport> todaysActivitiesDurationReportProjection;

  @override
  void initState() {
    todaysActivitiesDurationReportProjection?.stop();
    todaysActivitiesDurationReportProjection = widget.projectionFactory.getTodaysActivitiesDurationReport();
    todaysActivitiesDurationReportProjection.stream.forEach((report) {
      selectedActivities.retainAll(report.getActivityDurations(widget.clock.now()).map((ad) => ad.activityName));
    });
    timeRedrawingTimer = Timer.periodic(Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    timeRedrawingTimer?.cancel();
    todaysActivitiesDurationReportProjection?.stop();
  }

  void _handleRemoveSelection() {
    setState(() {
      selectedActivities.clear();
    });
  }

  void _handleItemClicked(ActivityDuration activityDuration) {
    setState(() {
      if (selectedActivities.contains(activityDuration.activityName)) {
        selectedActivities.remove(activityDuration.activityName);
      } else {
        selectedActivities.add(activityDuration.activityName);
      }
    });
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
                durationFormatter: widget.durationFormatter,
                onActivityDurationClicked: _handleItemClicked,
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
                durationFormatter: widget.durationFormatter,
                onRemoveSelection: _handleRemoveSelection,
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