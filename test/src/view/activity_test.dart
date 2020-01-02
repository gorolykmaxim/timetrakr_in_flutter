import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/query.dart';
import 'package:timetrakr_in_flutter/src/view/activity/view.dart';
import 'package:timetrakr_in_flutter/src/view/error.dart';

import '../common.dart';
import 'app_test.dart';

class ScaffoldStateMock extends DiagnosticableMixinFriendlyMock implements ScaffoldState {}

void assertErrorTextDisplayed(String text, ScaffoldState scaffoldState) {
  ErrorSnackBar snackBar = verify(scaffoldState.showSnackBar(captureAny)).captured.single;
  Text errorText = snackBar.content;
  expect(errorText.data, text);
}

void main() {
  group('StartedActivitiesViewState', () {
    final now = DateTime.now();
    final dateFormat = DateFormat();
    final clock = Clock.fixed(now);
    final activity = StartedActivity('doing nothing', now.subtract(Duration(hours: 8)));
    ActivityBoundedContext context;
    Projection<Specification, List<StartedActivity>> projection;
    ProjectionFactory factory;
    ScaffoldState scaffoldState;
    StartedActivitiesViewController controller;
    StartedActivitiesView widget;
    StartedActivitiesViewState state;
    setUp(() {
      context = ActivityBoundedContextMock();
      projection = ProjectionMock();
      factory = ProjectionFactoryMock();
      scaffoldState = ScaffoldStateMock();
      when(factory.findActivitiesStartedToday()).thenReturn(projection);
      when(context.startNewActivity(any, any)).thenAnswer((_) => Future.value(null));
      when(context.removeActivity(any)).thenAnswer((_) => Future.value(null));
      controller = StartedActivitiesViewController();
      widget = StartedActivitiesView(
          boundedContext: context,
          projectionFactory: factory,
          clock: clock,
          controller: controller,
          dateFormat: dateFormat,
      );
      state = widget.createState();
    });
    test('creates new projection on initialization', () {
      // when
      state.initialize(widget);
      // then
      expect(state.todaysActivitiesProjection, projection);
    });
    test('starts to listen to activity start requests on controller', () {
      // given
      final defaultHandler = controller.onRequestNewActivityStart;
      // when
      state.initialize(widget);
      // then
      expect(controller.onRequestNewActivityStart == defaultHandler, isFalse);
    });
    test('stops projection on disposal', () {
      // when
      state.initialize(widget);
      state.destroy();
      // then
      verify(projection.stop());
    });
    test('starts new activity', () async {
      // when
      await state.handleActivityStart(widget, activity.name, activity.startDate, scaffoldState);
      // then
      verify(context.startNewActivity(activity.name, activity.startDate));
    });
    test('fails to start a new activity and notifies user about the error via error snack bar', () async {
      // given
      final error = AnotherActivityAlreadyStartedException(activity);
      when(context.startNewActivity(activity.name, activity.startDate)).thenAnswer((_) => Future.error(error));
      // when
      await state.handleActivityStart(widget, activity.name, activity.startDate, scaffoldState);
      // then
      assertErrorTextDisplayed(error.format(dateFormat), scaffoldState);
    });
    test('removes activity', () async {
      // when
      await state.handleActivityDelete(widget, activity, scaffoldState);
      // then
      verify(context.removeActivity(activity));
    });
    test('fails to remove activity and notifies user about the error via error snack bar', () async {
      // given
      final error = ActivityStartModificationException.remove(activity.name, activity.startDate, '');
      when(context.removeActivity(activity)).thenAnswer((_) => Future.error(error));
      // when
      await state.handleActivityDelete(widget, activity, scaffoldState);
      // then
      assertErrorTextDisplayed(error.format(dateFormat), scaffoldState);
    });
  });
}