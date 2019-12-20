import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetrakr_in_flutter/src/view/animation.dart';

class DummyWidget extends StatelessWidget {
  final bool display;
  final Duration duration;

  DummyWidget({@required this.display, this.duration});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: FloatUpAnimation(
              child: Container(),
              display: display,
              duration: duration)
      )
    );
  }
}

Future<void> assertFloatUpAndDown(WidgetTester tester, Duration expectedDuration, [Duration animationDuration]) async {
  await tester.pumpWidget(DummyWidget(display: true, duration: animationDuration));
  RenderPositionedBox actualPositionedBox = tester.renderObject(find.byType(Align));
  expect(actualPositionedBox.heightFactor, 0);
  await tester.pumpAndSettle(expectedDuration);
  expect(actualPositionedBox.heightFactor, 1);
  await tester.pumpWidget(DummyWidget(display: false, duration: animationDuration));
  actualPositionedBox = tester.renderObject(find.byType(Align));
  expect(actualPositionedBox.heightFactor, 1);
  await tester.pumpAndSettle(expectedDuration);
  expect(actualPositionedBox.heightFactor, 0);
}

void main() {
  group('FloatUpAnimation', () {
    testWidgets('makes child widget float down after floating up', (WidgetTester tester) async {
      await assertFloatUpAndDown(tester, const Duration(milliseconds: 400));
    });
    testWidgets('makes child widget float down after floating up with custom duration', (WidgetTester tester) async {
      const expectedDuration = const Duration(milliseconds: 200);
      await assertFloatUpAndDown(tester, expectedDuration, expectedDuration);
    });
  });
}