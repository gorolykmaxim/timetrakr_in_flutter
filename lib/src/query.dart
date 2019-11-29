import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';

import 'model.dart';
import 'persistence.dart';

class FindActivitiesStartedToday implements Query<Specification, List<StartedActivity>> {
  final ImmutableCollection<StartedActivity> _startedActivities;

  FindActivitiesStartedToday(this._startedActivities);

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

class ProjectionFactory {
  final ImmutableCollection<StartedActivity> _startedActivities;
  final ObservableEventStream<Specification> _eventStream;

  ProjectionFactory(this._startedActivities, this._eventStream);

  Projection<Specification, List<StartedActivity>> findActivitiesStartedToday() {
    final query = FindActivitiesStartedToday(_startedActivities);
    final projection = Projection(query, [ActivityStarted.type, ActivityRemoved.type]);
    projection.start(_eventStream.stream);
    return projection;
  }
}