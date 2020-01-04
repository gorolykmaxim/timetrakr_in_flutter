import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_commons/flutter_commons.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/query.dart';
import 'package:timetrakr_in_flutter/src/view/report/view.dart';

import '../common.dart';

class WidgetsBindingMock extends Mock implements WidgetsBinding {}

void main() {
  group('ActivitiesReportViewState', () {
    final now = DateTime.now();
    final clock = Clock.fixed(now);
    final stateDouble = StateDouble();
    WidgetsBinding binding;
    Projection<Specification, ActivitiesDurationReport> projection;
    ApplicationProjectionFactory factory;
    ActivitiesReportView widget;
    ActivitiesReportViewState state;
    final activities = [
      StartedActivity('sleeping', now.subtract(Duration(hours: 1))),
      StartedActivity('working', now.subtract(Duration(minutes: 30)))
    ];
    final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder(activities);
    final activityDuration = report.getActivityDurations(now).first;
    setUp(() {
      binding = WidgetsBindingMock();
      projection = ProjectionMock();
      factory = TimeTrakrProjectionFactoryMock();
      when(projection.stream).thenAnswer((_) => Stream.empty());
      when(factory.getTodaysActivitiesDurationReport()).thenReturn(projection);
      widget = ActivitiesReportView(projectionFactory: factory, clock: clock);
      state = widget.createState();
    });
    test('creates new projection on initialization', () {
      // when
      state.initialize(widget, binding);
      // then
      expect(state.todaysActivitiesDurationReportProjection, projection);
    });
    test('removes activities from the selected list when a new report comes '
        'via projection, which does not have such activities', () {
      // given
      final expectedSelectedActivities = activities.map((a) => a.name).toSet();
      state.selectedActivities.addAll(expectedSelectedActivities);
      state.selectedActivities.add('activity, that was deleted');
      final controller = StreamController<ActivitiesDurationReport>(sync: true);
      when(projection.stream).thenAnswer((_) => controller.stream);
      // when
      state.initialize(widget, binding);
      controller.add(report);
      // then
      expect(state.selectedActivities, expectedSelectedActivities);
      controller.close();
    });
    test('starts listening to application lifecycle events on initialization', () {
      // when
      state.initialize(widget, binding);
      // then
      verify(binding.addObserver(state));
    });
    test('stops listening to application lifecycle events on dispose', () {
      // when
      state.initialize(widget, binding);
      state.destroy(binding);
      // then
      verify(binding.removeObserver(state));
    });
    test('stops projection on dispose', () {
      // when
      state.initialize(widget, binding);
      state.destroy(binding);
      // then
      verify(projection.stop());
    });
    test('clears selected activities', () {
      // given
      state.selectedActivities.add('activity');
      // when
      state.handleRemoveSelection(stateDouble);
      // then
      expect(state.selectedActivities, isEmpty);
    });
    test('removes selected activity from selection when clicking on it', () {
      // given
      state.selectedActivities.add(activityDuration.activityName);
      // when
      state.handleItemClicked(stateDouble, activityDuration);
      // then
      expect(state.selectedActivities, isEmpty);
    });
    test('selects activity when clicking on it', () {
      // when
      state.handleItemClicked(stateDouble, activityDuration);
      // then
      expect(state.selectedActivities, contains(activityDuration.activityName));
    });
  });
}