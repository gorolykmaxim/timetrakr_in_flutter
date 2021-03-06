import 'package:clock/clock.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';

import 'model.dart';
import 'persistence.dart';

class _FindActivitiesStartedToday implements Query<Specification, List<StartedActivity>> {
  final ImmutableCollection<StartedActivity> _startedActivities;
  final Clock _clock;

  _FindActivitiesStartedToday(this._startedActivities, this._clock);

  @override
  Future<List<StartedActivity>> execute() {
    final now = _clock.now();
    final todaysMidnight = DateTime(now.year, now.month, now.day);
    final todaysActivities = ActivitySpecification.startedAfter(todaysMidnight);
    return _startedActivities.findAll(todaysActivities);
  }

  @override
  Future<List<StartedActivity>> executeOn(Event<Specification> event) {
    return execute();
  }
}

class _GetTodaysActivitiesDurationReport implements Query<Specification, ActivitiesDurationReport> {
  final _FindActivitiesStartedToday _findActivitiesStartedToday;

  _GetTodaysActivitiesDurationReport(ImmutableCollection<StartedActivity> startedActivities, Clock clock):
        _findActivitiesStartedToday = _FindActivitiesStartedToday(startedActivities, clock);

  @override
  Future<ActivitiesDurationReport> execute() async {
    List<StartedActivity> startedActivities = await _findActivitiesStartedToday.execute();
    return ActivitiesDurationReport.fromActivitiesInChronologicalOrder(startedActivities);
  }

  @override
  Future<ActivitiesDurationReport> executeOn(Event<Specification> event) {
    return execute();
  }
}

/// Factory of all possible application's projections.
class ApplicationProjectionFactory extends ProjectionFactory<Specification> {
  final ImmutableCollection<StartedActivity> _startedActivities;
  final Clock _clock;

  /// Create projection factory, that will be executing created queries
  /// against [_startedActivities], while using [_clock] to determine current
  /// time.
  /// All projections, initialized by this factory, will be listening to events
  /// from [eventStream].
  ApplicationProjectionFactory(this._startedActivities, ObservableEventStream<Specification> eventStream, this._clock): super(eventStream);

  /// Create projection, that will look for all activities, started after
  /// today's midnight, when either a new activity starts or an existing
  /// activities gets removed.
  Projection<Specification, List<StartedActivity>> findActivitiesStartedToday() {
    return create(_FindActivitiesStartedToday(_startedActivities, _clock), [ActivityStartedEvent, ActivityRemovedEvent]);
  }

  /// Create projection, that will form report about durations of all activities,
  /// that were started today (after today's midnight).
  Projection<Specification, ActivitiesDurationReport> getTodaysActivitiesDurationReport() {
    return create(_GetTodaysActivitiesDurationReport(_startedActivities, _clock), [ActivityStartedEvent, ActivityRemovedEvent]);
  }
}