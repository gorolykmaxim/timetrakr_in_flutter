import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_repository_sqflite/flutter_repository_sqflite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/persistence.dart';

class DatabaseExecutorMock extends Mock implements DatabaseExecutor {}

void main() {
  final startDate = DateTime.now();
  group('StartedActivityDataSourceServant', () {
    // During serialization and deserialization current date precision will be lost.
    // Round current date to the expected degraded precision level.
    final startDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
    final activity = StartedActivity('chilling', startDate);
    final serializedActivity = <String, dynamic>{
      ActivityPersistence.name: activity.name,
      ActivityPersistence.startDate: startDate.millisecondsSinceEpoch
    };
    final servant = StartedActivityDataSourceServant();
    test('deserializes started activity', () {
      // when
      final actualActivity = servant.deserialize(serializedActivity);
      // then
      expect(actualActivity, activity);
    });
    test('serializes started activity', () {
      // when
      final actualSerializedActivity = servant.serialize(activity);
      // then
      expect(actualSerializedActivity, serializedActivity);
    });
    test('returns list of ID fields of started activity', () {
      expect(servant.idFieldNames, [ActivityPersistence.startDate]);
    });
  });
  group('ActivityPersistence', () {
    final persistence = ActivityPersistence();
    DatabaseExecutor executor;
    setUp(() {
      executor = DatabaseExecutorMock();
    });
    test('returns empty list if migration scripts for unknown version', () {
      expect(persistence.getMigrationScriptsFor(Version(3000)), []);
    });
    test('return list of migration scripts for version 1', () {
      // when
      final scripts = persistence.getMigrationScriptsFor(Version(1));
      scripts.forEach((s) => s.execute(executor));
      // then
      verify(executor.execute('CREATE TABLE StartedActivity(name VARCHAR NOT NULL, startDate INTEGER PRIMARY KEY)'));
    });
  });
  group('ActivitySpecification', () {
    test('creates specification to find all activity start events, that occurred at the specified date', () {
      expect(
          ActivitySpecification.startedAt(startDate),
          Specification()
              .equals(ActivityPersistence.startDate, startDate.millisecondsSinceEpoch)
      );
    });
    test('creates specification to find all activity start events in the order in which they have occurred before the specified date', () {
      expect(
          ActivitySpecification.startedAfter(startDate),
          Specification()
              .greaterThan(ActivityPersistence.startDate, startDate.millisecondsSinceEpoch)
              .appendOrderDefinition(Order.ascending(ActivityPersistence.startDate))
      );
    });
  });
}