import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_repository_sqflite/flutter_repository_sqflite.dart';

import 'model.dart';

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

class ActivityPersistence {
  static final _tableName = 'StartedActivity';
  static final name = 'name';
  static final startDate = 'startDate';

  List<MigrationScript> getMigrationScriptsFor(Version version) {
    if (version == Version(1)) {
      return [MigrationScript('CREATE TABLE $_tableName($name VARCHAR NOT NULL, $startDate INTEGER PRIMARY KEY)')];
    } else {
      return [];
    }
  }

  Collection<StartedActivity> getStartedActivitiesFrom(SqfliteDatabase database) {
    final servant = StartedActivityDataSourceServant();
    return SimpleCollection(database.table(_tableName), servant);
  }
}

class ActivitySpecification {
  static Specification startedAt(DateTime dateTime) {
    return Specification().equals(ActivityPersistence.startDate, dateTime.millisecondsSinceEpoch);
  }
  static Specification startedAfter(DateTime dateTime) {
    return Specification()
        .greaterThan(ActivityPersistence.startDate, dateTime.millisecondsSinceEpoch)
        .appendOrderDefinition(Order.ascending(ActivityPersistence.startDate));
  }
}