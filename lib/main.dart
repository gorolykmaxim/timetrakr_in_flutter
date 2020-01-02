import 'dart:async';

import 'package:clock/clock.dart';
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
  final clock = Clock();
  final controller = StreamController<Event<Specification>>.broadcast();
  final events = ObservableEventStream(controller);
  final activityPersistence = ActivityPersistence();
  final persistence = ApplicationPersistence(Version(1), [activityPersistence]);
  await persistence.initialize();
  final startedActivities = activityPersistence.getStartedActivities();
  final boundedContext = ActivityBoundedContext(startedActivities, events, clock);
  final projectionFactory = ApplicationProjectionFactory(startedActivities, events, clock);
  runApp(TimeTrakrApp(boundedContext: boundedContext, projectionFactory: projectionFactory, clock: clock));
}