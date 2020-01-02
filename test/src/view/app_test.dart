import 'package:clock/clock.dart';
import 'package:flutter_commons/flutter_commons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/query.dart';
import 'package:timetrakr_in_flutter/src/view/activity/view.dart';
import 'package:timetrakr_in_flutter/src/view/app.dart';
import 'package:timetrakr_in_flutter/src/view/report/view.dart';

import '../common.dart';

class ActivityBoundedContextMock extends Mock implements ActivityBoundedContext {}

void main() {
  group('TimeTrakrAppState', () {
    Clock clock = Clock.fixed(DateTime.now());
    final stateDouble = StateDouble();
    ActivityBoundedContext context;
    ApplicationProjectionFactory factory;
    TimeTrakrApp widget;
    TimeTrakrAppState state;
    setUp(() {
      context = ActivityBoundedContextMock();
      factory = TimeTrakrProjectionFactoryMock();
      widget = TimeTrakrApp(
          boundedContext: context,
          projectionFactory: factory,
          clock: clock
      );
      state = widget.createState();
    });
    test('displays activities started today by default', () {
      // when
      state.initialize(widget);
      // then
      expect(state.views[state.currentViewIndex], isInstanceOf<StartedActivitiesView>());
    });
    test('displays activity durations report', () {
      // when
      state.initialize(widget);
      state.changeCurrentView(stateDouble, 1);
      // then
      expect(state.views[state.currentViewIndex], isInstanceOf<ActivitiesReportView>());
    });
  });
}