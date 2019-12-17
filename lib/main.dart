import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_repository_sqflite/flutter_repository_sqflite.dart';

import 'src/model.dart';
import 'src/persistence.dart';
import 'src/query.dart';
import 'src/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = StreamController<Event<Specification>>.broadcast();
  final events = ObservableEventStream(controller);
  final activityPersistence = ActivityPersistence();
  final builder = SqfliteDatabaseBuilder();
  final version = Version(1);
  builder.version = version;
  builder.instructions(MigrationInstructions(version, activityPersistence.getMigrationScriptsFor(version)));
  final database = await builder.build();
  final startedActivities = activityPersistence.getStartedActivitiesFrom(database);
  final boundedContext = ActivityBoundedContext(startedActivities, events);
  final projectionFactory = ProjectionFactory(startedActivities, events);
  runApp(TimeTrakrApp(boundedContext, projectionFactory));
}