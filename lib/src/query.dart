import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';

import 'model.dart';
import 'persistence.dart';

class _FindActivitiesStartedToday implements Query<Specification, List<StartedActivity>> {
  final ImmutableCollection<StartedActivity> _startedActivities;

  _FindActivitiesStartedToday(this._startedActivities);

  @override
  Future<List<StartedActivity>> execute() {
    final now = DateTime.now();
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

  _GetTodaysActivitiesDurationReport(ImmutableCollection<StartedActivity> startedActivities): _findActivitiesStartedToday = _FindActivitiesStartedToday(startedActivities);

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

class ProjectionFactory {
  final ImmutableCollection<StartedActivity> _startedActivities;
  final ObservableEventStream<Specification> _eventStream;

  ProjectionFactory(this._startedActivities, this._eventStream);

  Projection<Specification, List<StartedActivity>> findActivitiesStartedToday() {
    final query = _FindActivitiesStartedToday(_startedActivities);
    final projection = Projection(query, [ActivityStarted.type, ActivityRemoved.type]);
    projection.start(_eventStream.stream);
    return projection;
  }

  Projection<Specification, ActivitiesDurationReport> getTodaysActivitiesDurationReport() {
    final query = _GetTodaysActivitiesDurationReport(_startedActivities);
    final projection = Projection(query, [ActivityStarted.type, ActivityRemoved.type]);
    projection.start(_eventStream.stream);
    return projection;
  }
}