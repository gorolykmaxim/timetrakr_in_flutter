abstract class DurationFormatter {
  factory DurationFormatter.hoursAndMinutes() {
    return _HourAndMinutesDurationFormatter();
  }
  String format(Duration duration);
}

class _HourAndMinutesDurationFormatter implements DurationFormatter {
  @override
  String format(Duration duration) {
    final result = <String>[];
    final hours = duration.inHours;
    if (hours > 0) {
      result.add('${hours}h');
    }
    int minutes = duration.inMinutes % Duration.minutesPerHour;
    // Round amount of minutes to the higher value to represent the seconds,
    // that are a remainder.
    if (duration.inSeconds - duration.inMinutes * Duration.secondsPerMinute > 0) {
      minutes++;
    }
    if (hours == 0 || minutes > 0) {
      result.add('${minutes}m');
    }
    return result.join(' ');
  }
}