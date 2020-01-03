/// Format in which a [Duration] can be displayed.
abstract class DurationFormat {
  /// Create format to display durations like:
  /// "15h 20m". Only hours and minutes will get displayed.
  /// Duration will get rounded to the higher value:
  /// duration of 5 minutes and 15 seconds will be displayed as "6m".
  factory DurationFormat.hoursAndMinutes() {
    return _HourAndMinutesDurationFormat();
  }
  /// Return string representation of [duration] according to this specific
  /// format.
  String applyTo(Duration duration);
}

class _HourAndMinutesDurationFormat implements DurationFormat {
  @override
  String applyTo(Duration duration) {
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