import 'package:clock/clock.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/persistence.dart';

import 'common.dart';

void main() {
  group('ActivityBoundedContext', () {
    Collection<StartedActivity> startedActivities;
    EventStream<Specification> events;
    const activityName = 'Working';
    final startDate = DateTime.now();
    final clock = Clock.fixed(startDate);
    ActivityBoundedContext context;
    setUp(() {
      startedActivities = SimpleCollectionMock();
      events = ObservableEventStreamMock();
      when(startedActivities.findAll(ActivitySpecification.startedAt(startDate)))
          .thenAnswer((_) => Future.value(<StartedActivity>[]));
      context = ActivityBoundedContext(startedActivities, events, clock);
    });
    test('fails to start new activity at the time when another activity has been stared', () {
      // given
      final existingActivities = [StartedActivity(activityName, startDate)];
      when(startedActivities.findAll(ActivitySpecification.startedAt(startDate)))
          .thenAnswer((_) => Future.value(existingActivities));
      // when
      expect(context.startNewActivity(activityName, startDate), throwsA(isInstanceOf<AnotherActivityAlreadyStartedException>()));
    });
    test('fails to start activity with start date set in future', () {
      // given
      final startDateInFuture = startDate.add(Duration(hours: 1));
      when(startedActivities.findAll(ActivitySpecification.startedAt(startDateInFuture)))
          .thenAnswer((_) => Future.value(<StartedActivity>[]));
      // when
      expect(context.startNewActivity(activityName, startDateInFuture), throwsA(isInstanceOf<StartActivityInFutureException>()));
    });
    test('fails to start activity with name that is too short', () {
      expect(context.startNewActivity('wk', startDate), throwsA(isInstanceOf<NewActivityNameIsTooShortException>()));
    });
    test('fails to save newly started activity', () {
      // given
      when(startedActivities.add(any))
          .thenAnswer((_) => Future.error(CollectionException('error')));
      // when
      expect(context.startNewActivity(activityName, startDate), throwsA(isInstanceOf<ActivityStartModificationException>()));
    });
    test('starts new activity and creates corresponding event', () async {
      // when
      await context.startNewActivity(activityName, startDate);
      // then
      verify(startedActivities.add(StartedActivity(activityName, startDate))).called(1);
      verify(events.publish(ActivityStartedEvent())).called(1);
    });
    test('fails to remove activity start event', () {
      // given
      final activityStart = StartedActivity(activityName, startDate);
      when(startedActivities.removeOne(activityStart))
          .thenAnswer((_) => Future.error(CollectionException('error')));
      // when
      expect(context.removeActivity(activityStart), throwsA(isInstanceOf<ActivityStartModificationException>()));
    });
    test('removes activity start event and creates corresponding event', () async {
      // given
      final activityStart = StartedActivity(activityName, startDate);
      // when
      await context.removeActivity(activityStart);
      // then
      verify(startedActivities.removeOne(activityStart)).called(1);
      verify(events.publish(ActivityRemovedEvent())).called(1);
    });
  });
  group('ActivitiesDurationReport', () {
    final activities = ['wake up', 'breakfast', 'sneeze', 'work', 'nothing'];
    final now = DateTime.now();
    final today = now.subtract(Duration(hours: 10));
    final wakeUp = StartedActivity('wake up', today.add(Duration(hours: 8)));
    final breakfast = StartedActivity('breakfast', today.add(Duration(hours: 8, minutes: 15)));
    final sneezeDuringBreakfast = StartedActivity('sneeze', today.add(Duration(hours: 8, minutes: 16)));
    final continueBreakfast = StartedActivity('breakfast', today.add(Duration(hours: 8, minutes: 16, seconds: 5)));
    final sneezeBeforeWork = StartedActivity('sneeze', today.add(Duration(hours: 8, minutes: 29, seconds: 55)));
    final work = StartedActivity('work', today.add(Duration(hours: 8, minutes: 30)));
    final nothing = StartedActivity('nothing', now.subtract(Duration(seconds: 48)));
    test('returns durations of activities that are longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, sneezeBeforeWork, work
      ]);
      // then
      final activityDurations = List<ActivityDuration>.from(report.getActivityDurations(now));
      expect(activityDurations[0], ActivityDuration('wake up', Duration(minutes: 15)));
      expect(activityDurations[1], ActivityDuration('breakfast', Duration(minutes: 14, seconds: 55)));
      expect(activityDurations[2], ActivityDuration('work', Duration(hours: 1, minutes: 30)));
    });
    test('treats several activity start events as a single activity duration', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, sneezeDuringBreakfast, continueBreakfast, work
      ]);
      // then
      final activityDurations = List<ActivityDuration>.from(report.getActivityDurations(now));
      expect(activityDurations[0], ActivityDuration('wake up', Duration(minutes: 15)));
      expect(activityDurations[1], ActivityDuration('breakfast', Duration(minutes: 14, seconds: 55)));
      expect(activityDurations[2], ActivityDuration('work', Duration(hours: 1, minutes: 30)));
    });
    test('is empty if there are no activity durations, that are longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([nothing]);
      // then
      expect(report.isEmptyAt(now), isTrue);
    });
    test('is not empty if there are activity durations, that are longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, work
      ]);
      // then
      expect(report.isEmptyAt(now), isFalse);
    });
    test('returns total duration of all activities that took longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, work
      ]);
      final totalDuration = report.totalDurationOf(activities, now);
      // then
      expect(totalDuration, Duration(hours: 2));
    });
    test('returns zero if there were no activities that took longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([nothing]);
      final totalDuration = report.totalDurationOf(activities, now);
      // then
      expect(totalDuration, Duration.zero);
    });
    test('returns zero if there were no specified activities that took longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, sneezeDuringBreakfast, continueBreakfast, sneezeBeforeWork, work
      ]);
      final totalDuration = report.totalDurationOf([sneezeBeforeWork.name], now);
      // then
      expect(totalDuration, Duration.zero);
    });
    test('return total duration of selected activities that took longer than 1 minute', () {
      // when
      final report = ActivitiesDurationReport.fromActivitiesInChronologicalOrder([
        wakeUp, breakfast, sneezeDuringBreakfast, continueBreakfast, sneezeBeforeWork, work
      ]);
      final totalDuration = report.totalDurationOf(activities, now);
      // then
      expect(totalDuration, Duration(hours: 1, minutes: 59, seconds: 50));
    });
  });
}