import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/query.dart';
import 'package:timetrakr_in_flutter/src/view/activity/button.dart';
import 'package:timetrakr_in_flutter/src/view/activity/view.dart';
import 'package:timetrakr_in_flutter/src/view/app.dart';
import 'package:timetrakr_in_flutter/src/view/bottom_navigation_bar.dart';
import 'package:timetrakr_in_flutter/src/view/report/view.dart';

import '../common.dart';

class ActivityBoundedContextMock extends Mock implements ActivityBoundedContext {}

void main() {
  group('TimeTrakrApp', () {
    final clock = Clock.fixed(DateTime.now());
    ActivityBoundedContext boundedContext;
    ProjectionFactory projectionFactory;
    StreamController controller;
    setUp(() {
      boundedContext = ActivityBoundedContextMock();
      controller = StreamController<Event<Specification>>.broadcast();
      final events = ObservableEventStream<Specification>(controller);
      final startedActivities = SimpleCollectionMock<StartedActivity>();
      when(startedActivities.findAll(any)).thenAnswer((_) => Future.value([]));
      projectionFactory = ProjectionFactory(startedActivities, events, clock);
    });
    tearDown(() {
      controller.close();
    });
    testWidgets('shows todays started activities view and a start new activity button', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(
          TimeTrakrApp(
              boundedContext: boundedContext,
              projectionFactory: projectionFactory,
              clock: clock
          )
      );
      // then
      expect(find.byType(StartedActivitiesView), findsOneWidget);
      expect(find.byType(ActivitiesReportView), findsOneWidget);
      expect(find.byType(TimeTrakrBottomNavigationBar), findsOneWidget);
      expect(find.byType(StartActivityFloatingButton), findsOneWidget);
    });
    testWidgets('switches to activities report view while removing a start new activity button', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(
        TimeTrakrApp(
            boundedContext: boundedContext,
            projectionFactory: projectionFactory,
            clock: clock
        )
      );
      await tester.tap(find.text('Results'));
      await tester.pump();
      // then
      IndexedStack stack = tester.widget(find.byType(IndexedStack));
      expect(stack.index, 1);
      Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.floatingActionButton, isNull);
    });
    testWidgets('switches to todays started activities view and shows a start new activity button', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(
          TimeTrakrApp(
              boundedContext: boundedContext,
              projectionFactory: projectionFactory,
              clock: clock
          )
      );
      await tester.tap(find.text('Results'));
      await tester.pump();
      await tester.tap(find.text('Activities'));
      await tester.pump();
      // then
      IndexedStack stack = tester.widget(find.byType(IndexedStack));
      expect(stack.index, 0);
      Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.floatingActionButton, isNotNull);
    });
  });
}