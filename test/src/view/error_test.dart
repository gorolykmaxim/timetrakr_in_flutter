import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetrakr_in_flutter/src/view/error.dart';

class DummyWidget extends StatelessWidget {
  final Object error;
  final Duration duration;
  static final Key tapTarget = Key('tap-target');

  DummyWidget({@required this.error, this.duration});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              Scaffold.of(context).showSnackBar(ErrorSnackBar(error: error, duration: duration));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 100,
              width: 100,
              key: tapTarget,
            ),
          );
        })
      ),
    );
  }
}

void main() {
  group('ErrorSnackBar', () {
    const errorMessage = 'Error message';
    testWidgets('displays snackbar with an error message for a default duration', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(DummyWidget(error: errorMessage));
      expect(find.text(errorMessage), findsNothing);
      await tester.tap(find.byKey(DummyWidget.tapTarget));
      await tester.pumpAndSettle(Duration(seconds: 1));
      // then
      expect(find.text(errorMessage), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text(errorMessage), findsNothing);
    });
    testWidgets('displays snackbar with an error message for a specified duration', (WidgetTester tester) async {
      // given
      const expectedDuration = const Duration(seconds: 2);
      // when
      await tester.pumpWidget(DummyWidget(error: errorMessage, duration: expectedDuration));
      expect(find.text(errorMessage), findsNothing);
      await tester.tap(find.byKey(DummyWidget.tapTarget));
      // then
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text(errorMessage), findsOneWidget);
      await tester.pumpAndSettle(expectedDuration);
      expect(find.text(errorMessage), findsNothing);
    });
  });
}