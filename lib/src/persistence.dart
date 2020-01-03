import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_repository_sqflite/flutter_repository_sqflite.dart';

import 'model.dart';

/// [DataSourceServant] of [StartedActivity].
class StartedActivityDataSourceServant implements DataSourceServant<StartedActivity> {
  @override
  StartedActivity deserialize(Map<String, dynamic> entity) {
    return StartedActivity(
        entity[ActivityPersistence.name],
        DateTime.fromMillisecondsSinceEpoch(entity[ActivityPersistence.startDate])
    );
  }

  @override
  Iterable<String> get idFieldNames => [ActivityPersistence.startDate];

  @override
  Map<String, dynamic> serialize(StartedActivity entity) {
    return {
      ActivityPersistence.name: entity.name,
      ActivityPersistence.startDate: entity.startDate.millisecondsSinceEpoch
    };
  }
}

/// Persistence of [StartedActivity].
class ActivityPersistence implements Persistence {
  static final _tableName = 'StartedActivity';
  static final name = 'name';
  static final startDate = 'startDate';
  SqfliteDatabase _database;

  /// Return collection of [StartedActivity]s, stored in the database.
  Collection<StartedActivity> getStartedActivities() {
    assert(_database != null, 'Initialize ApplicationPersistence before calling this method');
    final servant = StartedActivityDataSourceServant();
    return SimpleCollection(_database.table(_tableName), servant);
  }

  @override
  void initializeIn(SqfliteDatabaseBuilder builder) {
    builder.instructions(MigrationInstructions(
        Version(1),
        [
          MigrationScript('CREATE TABLE $_tableName($name VARCHAR NOT NULL, $startDate INTEGER PRIMARY KEY)')
        ]
    ));
  }

  @override
  void setDatabase(SqfliteDatabase database) {
    _database = database;
  }
}

/// Factory of all possible specifications, related to [StartedActivity].
class ActivitySpecification {
  /// Create a specification, that describes all [StartedActivity]s,
  /// started at [dateTime].
  static Specification startedAt(DateTime dateTime) {
    return Specification().equals(ActivityPersistence.startDate, dateTime.millisecondsSinceEpoch);
  }
  /// Create a specification, that describes all [StartedActivity]s,
  /// started after [dateTime].
  static Specification startedAfter(DateTime dateTime) {
    return Specification()
        .greaterThan(ActivityPersistence.startDate, dateTime.millisecondsSinceEpoch)
        .appendOrderDefinition(Order.ascending(ActivityPersistence.startDate));
  }
}