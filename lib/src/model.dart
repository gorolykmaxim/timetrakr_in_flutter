import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:intl/intl.dart';

import 'persistence.dart';

abstract class ActivityStartException implements Exception {
  String format(DateFormat dateFormat);

  @override
  String toString() {
    return format(DateFormat());
  }
}

class ActivityStartModificationException extends ActivityStartException {
  final String name;
  final DateTime startDate;
  final String operation;
  final Object cause;

  ActivityStartModificationException.create(this.name, this.startDate, this.cause): operation = 'start activity';
  ActivityStartModificationException.remove(this.name, this.startDate, this.cause): operation = 'remove start of activity';

  @override
  String format(DateFormat dateFormat) {
    return "Failed to $operation '$name' at ${dateFormat.format(startDate)}. Reason: $cause";
  }
}

class NewActivityNameIsTooShortException extends ActivityStartException {
  final String name;
  final int expectedMinimalLength;

  NewActivityNameIsTooShortException(this.name, this.expectedMinimalLength);

  @override
  String format(DateFormat dateFormat) {
    return "Activity name '$name' is too short. Use activity name with at least $expectedMinimalLength characters.";
  }
}

class StartActivityInFutureException extends ActivityStartException {
  final DateTime currentDate, specifiedDate;

  StartActivityInFutureException(this.currentDate, this.specifiedDate);

  @override
  String format(DateFormat dateFormat) {
    return 'Cannot start activity in the future. It is ${dateFormat.format(currentDate)} right now, and user tried to specify ${dateFormat.format(specifiedDate)}.';
  }
}

class AnotherActivityAlreadyStartedException extends ActivityStartException {
  final StartedActivity anotherActivity;

  AnotherActivityAlreadyStartedException(this.anotherActivity);

  @override
  String format(DateFormat dateFormat) {
    return '${anotherActivity.name} has already been started at ${dateFormat.format(anotherActivity.startDate)}.';
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

  ActivityDuration getDurationBeforeEndingAt(DateTime endDate) => ActivityDuration(name, endDate.difference(startDate));

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
    try {
      final activitiesStartedAtThisTime = ActivitySpecification.startedAt(startDate);
      final activities = await _startedActivities.findAll(activitiesStartedAtThisTime);
      if (activities.isNotEmpty) {
        throw AnotherActivityAlreadyStartedException(activities[0]);
      }
      await _startedActivities.add(StartedActivity.create(activityName, startDate: startDate));
      _events.publish(ActivityStarted());
    } on CollectionException catch (e) {
      throw ActivityStartModificationException.create(activityName, startDate, e);
    }
  }

  Future<void> removeActivity(StartedActivity activity) async {
    try {
      await _startedActivities.removeOne(activity);
      _events.publish(ActivityRemoved());
    } on CollectionException catch (e) {
      throw ActivityStartModificationException.remove(activity.name, activity.startDate, e);
    }
  }
}

class ActivityDuration {
  final String activityName;
  final Duration duration;

  ActivityDuration(this.activityName, this.duration);

  ActivityDuration prolongBy(Duration duration) => ActivityDuration(activityName, this.duration + duration);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActivityDuration &&
              runtimeType == other.runtimeType &&
              activityName == other.activityName &&
              duration == other.duration;

  @override
  int get hashCode =>
      activityName.hashCode ^
      duration.hashCode;

  @override
  String toString() {
    return 'ActivityDuration{activityName: $activityName, duration: $duration}';
  }
}

class ActivitiesDurationReport {
  final List<StartedActivity> _startedActivities;

  ActivitiesDurationReport.fromActivitiesInChronologicalOrder(this._startedActivities);

  Iterable<ActivityDuration> get _activityDurations {
    final activitiesFound = Set<String>();
    final activityNameToDuration = <String, ActivityDuration>{};
    for (var i = 0; i < _startedActivities.length; i++) {
      final activity = _startedActivities[i];
      activitiesFound.add(activity.name);
      StartedActivity nextActivity;
      if (i + 1 < _startedActivities.length) {
        nextActivity = _startedActivities[i + 1];
      } else {
        nextActivity = StartedActivity.create(activitiesFound.toString());
      }
      final activityDuration = activity.getDurationBeforeEndingAt(nextActivity.startDate);
      var existingActivityDuration = activityNameToDuration[activity.name];
      if (existingActivityDuration == null) {
        existingActivityDuration = activityDuration;
      } else {
        existingActivityDuration = existingActivityDuration.prolongBy(activityDuration.duration);
      }
      activityNameToDuration[activity.name] = existingActivityDuration;
    }
    return activityNameToDuration.values;
  }

  Iterable<ActivityDuration> get activityDurations => _activityDurations.where((a) => a.duration.inMinutes > 1);

  bool get isEmpty => activityDurations.isEmpty;

  Duration totalDurationOf(Iterable<String> activities) {
    final durations = activityDurations
        .where((ad) => activities.contains(ad.activityName))
        .map((ad) => ad.duration);
    if (durations.isEmpty) {
      return Duration.zero;
    } else {
      return durations.reduce((total, duration) => total + duration);
    }
  }
}