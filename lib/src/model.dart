import 'package:clock/clock.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'persistence.dart';

const _iterableEquals = const IterableEquality();

/// Base class for all exceptions, related to operations, done on activities.
abstract class ActivityStartException implements Exception {
  /// Return message of this exception, while using [dateFormat] for all
  /// dates, described in this exception.
  String format(DateFormat dateFormat);

  @override
  String toString() {
    return format(DateFormat());
  }
}

/// Generic error, that can occur when starting a new activity or removing
/// an existing one. This kind of exception indicates problems with
/// the collection, that stores started activities.
class ActivityStartModificationException extends ActivityStartException {
  final String name;
  final DateTime startDate;
  final String operation;
  final Object cause;

  /// Create exception, that describes a failed attempt to start activity
  /// with [name] at [startDate] due to [cause].
  ActivityStartModificationException.create(this.name, this.startDate, this.cause): operation = 'start activity';
  /// Create exception, that describes a failed attempt to remove activity
  /// with [name] started at [startDate], which occurred due to [cause].
  ActivityStartModificationException.remove(this.name, this.startDate, this.cause): operation = 'remove start of activity';

  @override
  String format(DateFormat dateFormat) {
    return "Failed to $operation '$name' at ${dateFormat.format(startDate)}. Reason: $cause";
  }
}

/// Error that can happen when a new activity is started, length of name of
/// which is shorter than the specified value.
class NewActivityNameIsTooShortException extends ActivityStartException {
  final String name;
  final int expectedMinimalLength;

  /// Create exception, that indicates that activity [name] is shorter than
  /// the [expectedMinimalLength].
  NewActivityNameIsTooShortException(this.name, this.expectedMinimalLength);

  @override
  String format(DateFormat dateFormat) {
    return "Activity name '$name' is too short. Use activity name with at least $expectedMinimalLength characters.";
  }
}

/// Error that can happen when a new activity is started with start date
/// set after current time.
/// Activity can be started in past, since the thing happened in the past
/// is a fact. Activity can't be started in advance since you can never
/// be sure about what can happen in a coming moment.
class StartActivityInFutureException extends ActivityStartException {
  final DateTime currentDate, specifiedDate;

  /// Create exception, that indicates that activity was started with
  /// [specifiedDate], which is greater than [currentDate].
  StartActivityInFutureException(this.currentDate, this.specifiedDate);

  @override
  String format(DateFormat dateFormat) {
    return 'Cannot start activity in the future. It is ${dateFormat.format(currentDate)} right now, and user tried to specify ${dateFormat.format(specifiedDate)}.';
  }
}

/// Error that can happen when a new activity is started at the exact same
/// time another activity has been started.
/// We assume that a user can't work on two different tasks at the same time.
class AnotherActivityAlreadyStartedException extends ActivityStartException {
  final StartedActivity anotherActivity;

  /// Create exceptions, that indicates that there was an attempt to start
  /// an activity at the same time when [anotherActivity] has been started.
  AnotherActivityAlreadyStartedException(this.anotherActivity);

  @override
  String format(DateFormat dateFormat) {
    return '${anotherActivity.name} has already been started at ${dateFormat.format(anotherActivity.startDate)}.';
  }
}

/// Factory of [StartedActivity].
class StartedActivityFactory {
  static final int expectedMinimalNameLength = 3;
  final Clock _clock;

  /// Create factory of started activities, that will start new activities
  /// with a start date, dictated by the current time, displayed by [_clock].
  StartedActivityFactory(this._clock);

  /// Start new activity with [name].
  ///
  /// The activity will be started at [startDate] if the latter one is
  /// specified. Otherwise - activity will be started at the current time.
  /// [startDate] should not be set to future (e.g. greater than current time).
  ///
  /// [name] of started activity should be longer than
  /// [expectedMinimalNameLength].
  StartedActivity create(String name, {DateTime startDate}) {
    final now = _clock.now();
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
}

/// An activity, started by user at some point in time.
class StartedActivity {
  final String name;
  final DateTime startDate;

  /// Create started activity, that has a [name] and was started at [startDate].
  StartedActivity(this.name, this.startDate);
  /// Calculate duration of this activity if it would have ended at [endDate].
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

/// Event that indicates that a new activity has been started.
class ActivityStartedEvent extends Event<Specification> {
  /// Create activity start event.
  ActivityStartedEvent() : super(ActivityStartedEvent, {});
}

/// Event that indicates that an existing activity has been removed.
class ActivityRemovedEvent extends Event<Specification> {
  ActivityRemovedEvent(): super(ActivityRemovedEvent, {});
}

/// Bounded context of activity domain model. Acts as a facade to all business
/// logic, related to activities.
class ActivityBoundedContext {
  final StartedActivityFactory _activityFactory;
  final Collection<StartedActivity> _startedActivities;
  final EventStream<Specification> _events;

  /// Create bounded context, that will store activities in [_startedActivities],
  /// publish events about operations, performed on activities, onto [_events].
  /// [clock] will be used in all operations to determine current time.
  ActivityBoundedContext(this._startedActivities, this._events, Clock clock):
        _activityFactory = StartedActivityFactory(clock);

  /// Start a new activity with [activityName] at [startDate].
  /// In addition to constraints in regards of [StartedActivity] creation (
  /// which are described in it's factory: [StartedActivityFactory]),
  /// an activity can't be started at the same time another activity have
  /// been started.
  /// This operation will create a new [StartedActivity], save it and publish
  /// [ActivityStartedEvent].
  Future<void> startNewActivity(String activityName, DateTime startDate) async {
    try {
      final activitiesStartedAtThisTime = ActivitySpecification.startedAt(startDate);
      final activities = await _startedActivities.findAll(activitiesStartedAtThisTime);
      if (activities.isNotEmpty) {
        throw AnotherActivityAlreadyStartedException(activities[0]);
      }
      await _startedActivities.add(_activityFactory.create(activityName, startDate: startDate));
      _events.publish(ActivityStartedEvent());
    } on CollectionException catch (e) {
      throw ActivityStartModificationException.create(activityName, startDate, e);
    }
  }

  /// Remove the fact, that [activity] has been started, from history.
  /// This operation will remove [activity] from it's collection and publish
  /// [ActivityRemovedEvent].
  Future<void> removeActivity(StartedActivity activity) async {
    try {
      await _startedActivities.removeOne(activity);
      _events.publish(ActivityRemovedEvent());
    } on CollectionException catch (e) {
      throw ActivityStartModificationException.remove(activity.name, activity.startDate, e);
    }
  }
}

/// Amount of time a user spent on an activity.
class ActivityDuration {
  final String activityName;
  final Duration duration;

  /// Create a [duration] of activity with [activityName].
  ActivityDuration(this.activityName, this.duration);

  /// Prolong duration of this activity by the specified [duration] and
  /// return resulting activity duration.
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

/// A report on who much time a user has spent on each of their's activities.
class ActivitiesDurationReport {
  final List<StartedActivity> _startedActivities;

  /// Create a duration report from a list of [_startedActivities], that are
  /// ordered in their chronological order from the oldest activity started,
  /// to the latest one.
  ActivitiesDurationReport.fromActivitiesInChronologicalOrder(this._startedActivities);

  Iterable<ActivityDuration> _getActivityDurations(DateTime time) {
    final activitiesFound = Set<String>();
    final activityNameToDuration = <String, ActivityDuration>{};
    for (var i = 0; i < _startedActivities.length; i++) {
      final activity = _startedActivities[i];
      activitiesFound.add(activity.name);
      StartedActivity nextActivity;
      if (i + 1 < _startedActivities.length) {
        nextActivity = _startedActivities[i + 1];
      } else {
        nextActivity = StartedActivity(activitiesFound.toString(), time);
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
  /// Get list of all activities, on which a user have been working at [time],
  /// and their durations.
  ///
  /// Each activity is presented in this list only once, meaning if one
  /// activity had been interrupted by another activity and then has resumed -
  /// returned list will display total duration of that activity.
  ///
  /// The report will not consider activities, that took less than one minute:
  /// such activities will be omitted.
  ///
  /// All the activities will be returned in the order in which they were
  /// started for the first time.
  Iterable<ActivityDuration> getActivityDurations(DateTime time) => _getActivityDurations(time).where((a) => a.duration.inMinutes > 1);

  /// Check if according to this report a user has been working on any
  /// activities at [time].
  ///
  /// Only those activities, that took more than 1 minute, are considered.
  bool isEmptyAt(DateTime time) => getActivityDurations(time).isEmpty;

  /// Check on which activities the user has been working at [time] and return
  /// a total duration of those of them, that have a name, that is present in
  /// [activities] list.
  ///
  /// Activities that took less than 1 minute will not be considered.
  ///
  /// This method will ignore those of [activities] that are not present in
  /// this report.
  Duration totalDurationOf(Iterable<String> activities, DateTime time) {
    final durations = getActivityDurations(time)
        .where((ad) => activities.contains(ad.activityName))
        .map((ad) => ad.duration);
    if (durations.isEmpty) {
      return Duration.zero;
    } else {
      return durations.reduce((total, duration) => total + duration);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActivitiesDurationReport &&
              runtimeType == other.runtimeType &&
              _iterableEquals.equals(_startedActivities, other._startedActivities);

  @override
  int get hashCode => _startedActivities.hashCode;
}