import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/persistence.dart';
import 'package:timetrakr_in_flutter/src/query.dart';

void main() {
  group('ApplicationProjectionFactory', () {
    final now = DateTime.now();
    final clock = Clock.fixed(now);
    final today = DateTime(now.year, now.month, now.day);
    final specification = ActivitySpecification.startedAfter(today);
    final expectedActivities = [
      StartedActivity('doing part time work', now),
      StartedActivity('doing main work', now)
    ];
    final expectedReport = ActivitiesDurationReport.fromActivitiesInChronologicalOrder(expectedActivities);
    ImmutableCollection<StartedActivity> startedActivities;
    StreamController controller;
    ObservableEventStream<Specification> observableEventStream;
    ApplicationProjectionFactory factory;
    setUp(() {
      controller = StreamController<Event<Specification>>.broadcast();
      observableEventStream = ObservableEventStream(controller);
      startedActivities = SimpleCollectionMock();
      when(startedActivities.findAll(specification))
          .thenAnswer((_) => Future.value(expectedActivities));
      factory = ApplicationProjectionFactory(startedActivities, observableEventStream, clock);
    });
    tearDown(() {
      controller.close();
    });
    test('finds all activities started today', () {
      // when
      final projection = factory.findActivitiesStartedToday();
      // then
      expect(projection.stream, emitsInOrder([
        expectedActivities
      ]));
    });
    test('finds all activities started today after an activity start', () {
      // when
      final projection = factory.findActivitiesStartedToday();
      observableEventStream.publish(ActivityStartedEvent());
      // then
      expect(projection.stream, emitsInOrder([
        expectedActivities,
        expectedActivities
      ]));
    });
    test('finds all activities started today after an activity removal', () {
      // when
      final projection = factory.findActivitiesStartedToday();
      observableEventStream.publish(ActivityRemovedEvent());
      // then
      expect(projection.stream, emitsInOrder([
        expectedActivities,
        expectedActivities
      ]));
    });
    test("gets today's activities duration report", () {
      // when
      final projection = factory.getTodaysActivitiesDurationReport();
      // then
      expect(projection.stream, emitsInOrder([
        expectedReport
      ]));
    });
    test("gets today's activities duration report after an activity start", () {
      // when
      final projection = factory.getTodaysActivitiesDurationReport();
      observableEventStream.publish(ActivityStartedEvent());
      // then
      expect(projection.stream, emitsInOrder([
        expectedReport,
        expectedReport
      ]));
    });
    test("gets today's activities duration report after an activity removal", () {
      // when
      final projection = factory.getTodaysActivitiesDurationReport();
      observableEventStream.publish(ActivityRemovedEvent());
      // then
      expect(projection.stream, emitsInOrder([
        expectedReport,
        expectedReport
      ]));
    });
  });
}