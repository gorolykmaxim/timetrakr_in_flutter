import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/duration.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/query.dart';
import 'package:timetrakr_in_flutter/src/view/animation.dart';
import 'package:timetrakr_in_flutter/src/view/report/view.dart';

import '../common.dart';

class DummyWidget extends StatelessWidget {
  final ProjectionFactory factory;
  final Clock clock;
  final DurationFormatter formatter;

  DummyWidget({this.factory, this.clock, this.formatter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ActivitiesReportView(
          projectionFactory: factory,
          clock: clock,
          durationFormatter: formatter,
        ),
      ),
    );
  }
}

class ActivitiesDurationReportMock extends Mock implements ActivitiesDurationReport {}

Future<void> assertTotalDurationDisplayed(
    Iterable<ActivityDuration> durations, ActivitiesDurationReport report,
    ProjectionFactory factory, DurationFormatter formatter, Clock clock,
    WidgetTester tester) async {
  // given
  final totalDuration = durations.map((d) => d.duration).reduce((r, d) => r + d);
  when(report.totalDurationOf(durations.map((d) => d.activityName).toSet(), clock.now()))
      .thenReturn(totalDuration);
  // when
  await tester.pumpWidget(DummyWidget(factory: factory, clock: clock, formatter: formatter));
  await tester.pump();
  for (var duration in durations) {
    await tester.tap(find.text(duration.activityName));
  }
  await tester.pump();
  // then
  FloatUpAnimation animation = tester.widget(find.byType(FloatUpAnimation));
  expect(animation.display, isTrue);
  expect(find.text('Total duration: ${formatter.format(totalDuration)}'), findsOneWidget);
}

Future<void> assertTotalDurationIsRemoved(
    Iterable<ActivityDuration> durations, DurationFormatter formatter,
    WidgetTester tester) async {
  // when
  for (var duration in durations) {
    await tester.tap(find.text(duration.activityName));
  }
  await tester.pump();
  // then
  FloatUpAnimation animation = tester.widget(find.byType(FloatUpAnimation));
  expect(animation.display, isFalse);
  expect(find.text('Total duration: ${formatter.format(Duration.zero)}'), findsOneWidget);
}

void main() {
  group('ActivitiesReportView', () {
    final now = DateTime.now();
    final clock = Clock.fixed(now);
    final formatter = DurationFormatter.hoursAndMinutes();
    final durations = [
      ActivityDuration('sleeping', Duration(hours: 6)),
      ActivityDuration('eating', Duration(minutes: 15)),
      ActivityDuration('working', Duration(hours: 8))
    ];
    ProjectionFactory factory;
    Projection<Specification, ActivitiesDurationReport> projection;
    ActivitiesDurationReport report;
    setUp(() {
      factory = ProjectionFactoryMock();
      projection = ProjectionMock();
      report = ActivitiesDurationReportMock();
      when(report.getActivityDurations(now)).thenReturn(durations);
      when(report.isEmptyAt(now)).thenReturn(false);
      when(report.totalDurationOf(any, now)).thenReturn(Duration.zero);
      when(projection.stream).thenAnswer((_) => Stream.value(report));
      when(factory.getTodaysActivitiesDurationReport()).thenReturn(projection);
    });
    testWidgets('displays a placeholder when there are no activities', (WidgetTester tester) async {
      // given
      when(report.isEmptyAt(now)).thenReturn(true);
      // when
      await tester.pumpWidget(DummyWidget(factory: factory, clock: clock, formatter: formatter));
      await tester.pump();
      // then
      expect(find.text('Here you will see how much time each of your todays activities took you'), findsOneWidget);
      expect(find.text('Todays activities'), findsNothing);
    });
    testWidgets('displays a list of durations of todays activities', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(DummyWidget(factory: factory, clock: clock, formatter: formatter));
      await tester.pump();
      // then
      expect(find.text('Todays activities'), findsOneWidget);
      for (var duration in durations) {
        expect(find.text(duration.activityName), findsOneWidget);
        expect(find.text(formatter.format(duration.duration)), findsOneWidget);
      }
    });
    testWidgets('highlights an activity when it is selected', (WidgetTester tester) async {
      await assertTotalDurationDisplayed([durations[0]], report, factory, formatter, clock, tester);
    });
    testWidgets('removes highlight off of a previously selected activity on click', (WidgetTester tester) async {
      await assertTotalDurationDisplayed([durations[0]], report, factory, formatter, clock, tester);
      await assertTotalDurationIsRemoved([durations[0]], formatter, tester);
    });
    testWidgets('displays total duration of multiple selected activities', (WidgetTester tester) async {
      await assertTotalDurationDisplayed(durations, report, factory, formatter, clock, tester);
    });
    testWidgets('hides total duration when the last selected activity gets de-selected', (WidgetTester tester) async {
      await assertTotalDurationDisplayed(durations, report, factory, formatter, clock, tester);
      await assertTotalDurationIsRemoved(durations, formatter, tester);
    });
  });
}