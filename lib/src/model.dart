import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';

import 'persistence.dart';

class ActivityStartException implements Exception {}

class NewActivityNameIsTooShortException extends ActivityStartException {
  final String name;
  final int expectedMinimalLength;

  NewActivityNameIsTooShortException(this.name, this.expectedMinimalLength);

  @override
  String toString() {
    return "Activity name '$name' is too short. Use activity name with at least $expectedMinimalLength characters.";
  }
}

class StartActivityInFutureException extends ActivityStartException {
  final DateTime currentDate, specifiedDate;

  StartActivityInFutureException(this.currentDate, this.specifiedDate);

  @override
  String toString() {
    return 'Cannot start activity in the future. It is $currentDate right now, and user tried to specify $specifiedDate.';
  }
}

class AnotherActivityAlreadyStartedException extends ActivityStartException {
  final StartedActivity anotherActivity;

  AnotherActivityAlreadyStartedException(this.anotherActivity);

  @override
  String toString() {
    return '${anotherActivity.name} has already been started at ${anotherActivity.startDate}.';
  }
}

class StartedActivity {
  static final int expectedMinimalNameLength = 3;
  final String name;
  final DateTime startDate;

  StartedActivity(this.name, this.startDate);

  factory StartedActivity.create(String name, {DateTime startDate}) {
    final now = DateTime.now();
    if (startDate == null) {
      startDate = now;
    } else if (startDate.isAfter(now)) {
      throw StartActivityInFutureException(now, startDate);
    }
    if (name.length < expectedMinimalNameLength) {
      throw NewActivityNameIsTooShortException(name, expectedMinimalNameLength);
    }
    return StartedActivity(name, startDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StartedActivity &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              startDate == other.startDate;

  @override
  int get hashCode =>
      name.hashCode ^
      startDate.hashCode;

  @override
  String toString() {
    return 'StartedActivity{name: $name, startDate: $startDate}';
  }
}

class ActivityStarted extends Event<Specification> {
  static final type = 'An activity has been started';
  ActivityStarted() : super(type, {});
}

class ActivityRemoved extends Event<Specification> {
  static final type = 'An activity start event has been removed';
  ActivityRemoved(): super(type, {});
}

class ActivityBoundedContext {
  final Collection<StartedActivity> _startedActivities;
  final EventStream<Specification> _events;

  ActivityBoundedContext(this._startedActivities, this._events);

  Future<void> startNewActivity(String activityName, DateTime startDate) async {
    final activitiesStartedAtThisTime = ActivitySpecification.startedAt(startDate);
    final activities = await _startedActivities.findAll(activitiesStartedAtThisTime);
    if (activities.isNotEmpty) {
      throw AnotherActivityAlreadyStartedException(activities[0]);
    }
    await _startedActivities.add(StartedActivity.create(activityName, startDate: startDate));
    _events.publish(ActivityStarted());
  }

  Future<void> removeActivity(StartedActivity activity) async {
    await _startedActivities.removeOne(activity);
    _events.publish(ActivityRemoved());
  }
}