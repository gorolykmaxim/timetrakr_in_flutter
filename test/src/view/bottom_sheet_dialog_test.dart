import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_commons/flutter_commons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/model.dart';
import 'package:timetrakr_in_flutter/src/view/activity/bottom_sheet_dialog.dart';

class BuildContextMock extends Mock implements BuildContext {}

class InjectableDialogContainerMock extends Mock implements InjectableDialogContainer {}

class NavigatorStateMock extends DiagnosticableMixinFriendlyMock implements NavigatorState {}

void main() {
  group('StartActivityBottomSheetDialogState', () {
    final now = DateTime.now();
    final activity = StartedActivity('working', now);
    final stateDouble = StateDouble();
    NavigatorState navigatorState;
    InjectableDialogContainer dialogContainer;
    StartActivityBottomSheetDialog widget;
    StartActivityBottomSheetDialogState state;
    setUp(() {
      navigatorState = NavigatorStateMock();
      dialogContainer = InjectableDialogContainerMock();
      widget = StartActivityBottomSheetDialog(startDate: now);
      state = widget.createState();
      state.dialogContainer = dialogContainer;
    });
    test('displays specified activity name in the text field', () {
      // given
      widget = StartActivityBottomSheetDialog(startDate: now, activityName: 'work');
      // when
      state.initialize(widget);
      // then
      expect(state.controller.text, widget.activityName);
    });
    test('displays specified start date in the text', () {
      // when
      state.initialize(widget);
      // then
      expect(state.startDate, widget.startDate);
    });
    test('displays empty string as an activity name in the text field', () {
      // when
      state.initialize(widget);
      // then
      expect(state.controller.text, '');
    });
    test('does not complete if specified activity name is empty', () {
      // given
      widget = StartActivityBottomSheetDialog(
          startDate: now,
          onStartActivity: (_, __) => fail('dialog should not complete with an empty activity name'),
      );
      // when
      state.initialize(widget);
      state.startActivity(widget, navigatorState);
    });
    test('call callback on completion and pops last navigator state', () {
      // given
      widget = StartActivityBottomSheetDialog(
          startDate: now,
          onStartActivity: (String name, DateTime startDate) {
            expect(name, activity.name);
            expect(startDate, activity.startDate);
          },
      );
      // when
      state.initialize(widget);
      state.controller.text = activity.name;
      state.startActivity(widget, navigatorState);
      verify(navigatorState.pop());
    });
    test('does not change start date if user has cancelled time picker dialog', () async {
      // given
      when(dialogContainer.showTimePicker(
          context: anyNamed('context'),
          initialTime: anyNamed('initialTime'),
          builder: anyNamed('builder'))).thenAnswer((_) => Future.value(null));
      // when
      state.initialize(widget);
      final expectedStartDate = state.startDate;
      await state.handleTimeChange(stateDouble, BuildContextMock());
      // then
      expect(state.startDate, expectedStartDate);
    });
    test('changes start date to the one, specified by user in the time picker dialog', () async {
      // given
      final expectedStartDate = DateTime(
        widget.startDate.year,
        widget.startDate.month,
        widget.startDate.day
      );
      when(dialogContainer.showTimePicker(
          context: anyNamed('context'),
          initialTime: anyNamed('initialTime'),
          builder: anyNamed('builder'))).thenAnswer((_) => Future.value(TimeOfDay.fromDateTime(expectedStartDate)));
      // when
      state.initialize(widget);
      await state.handleTimeChange(stateDouble, BuildContextMock());
      // then
      expect(state.startDate, expectedStartDate);
    });
  });
}