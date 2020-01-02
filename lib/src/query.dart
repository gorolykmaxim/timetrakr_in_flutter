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

class ApplicationProjectionFactory extends ProjectionFactory<Specification> {
  final ImmutableCollection<StartedActivity> _startedActivities;
  final Clock _clock;

  ApplicationProjectionFactory(this._startedActivities, ObservableEventStream<Specification> eventStream, this._clock): super(eventStream);

  Projection<Specification, List<StartedActivity>> findActivitiesStartedToday() {
    return create(_FindActivitiesStartedToday(_startedActivities, _clock), [ActivityStartedEvent, ActivityRemovedEvent]);
  }

  Projection<Specification, ActivitiesDurationReport> getTodaysActivitiesDurationReport() {
    return create(_GetTodaysActivitiesDurationReport(_startedActivities, _clock), [ActivityStartedEvent, ActivityRemovedEvent]);
  }
}