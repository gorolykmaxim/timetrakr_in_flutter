import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetrakr_in_flutter/src/view/bottom_navigation_bar.dart';

class DummyWidget extends StatelessWidget {
  final ValueChanged<int> onCurrentViewChange;

  DummyWidget({this.onCurrentViewChange});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: TimeTrakrBottomNavigationBar(
          onCurrentViewChange: onCurrentViewChange,
        ),
      ),
    );
  }
}

void main() {
  group('TimeTrakrBottomNavigationBar', () {
    const resultsIndex = 1;
    testWidgets('selects activities view by default', (WidgetTester tester) async {
      // when
      await tester.pumpWidget(DummyWidget());
      // then
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      BottomNavigationBar bar = tester.widget(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 0);
    });
    testWidgets('changes selection to results view and notifies callback', (WidgetTester tester) async {
      await tester.pumpWidget(DummyWidget(onCurrentViewChange: expectAsync1((int i) {
        expect(i, resultsIndex);
      })));
      await tester.tap(find.text('Results'));
    });
  });
}