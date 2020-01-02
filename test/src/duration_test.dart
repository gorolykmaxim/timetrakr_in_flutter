import 'package:flutter_test/flutter_test.dart';
import 'package:timetrakr_in_flutter/src/duration.dart';

void main() {
  group('hours and minutes', () {
    final format = DurationFormat.hoursAndMinutes();
    test('formats duration with only hours in it', () {
      expect(format.applyTo(Duration(hours: 5)), '5h');
    });
    test('formats duration with only minutes in it', () {
      expect(format.applyTo(Duration(minutes: 15)), '15m');
    });
    test('formats duration with hours and minutes in it but with no seconds remainder', () {
      expect(format.applyTo(Duration(hours: 2, minutes: 31)), '2h 31m');
    });
    test('formats duration with hours, minutes and a seconds remainder, rounding minutes to a higher number', () {
      expect(format.applyTo(Duration(hours: 2, minutes: 31, seconds: 15)), '2h 32m');
    });
  });
}