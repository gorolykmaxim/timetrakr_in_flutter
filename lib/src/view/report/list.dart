import 'package:flutter/material.dart';

import '../../duration.dart';
import '../../model.dart';

/// Callback called when user clicks on one of activity durations.
typedef OnActivityDurationClicked = void Function(ActivityDuration activityDuration);

/// Displays list of [ActivityDuration]s and allows selecting individual
/// activity durations.
class ActivityDurationList extends StatelessWidget {
  final Iterable<ActivityDuration> activityDurations;
  final OnActivityDurationClicked onActivityDurationClicked;
  final Iterable<String> selectedActivities;
  final DurationFormat durationFormat;

  /// Create a list of [activityDurations]. Activities with names, that are
  /// present in [selectedActivities], will be highlighted as selected.
  /// Durations of activities will be formatted in [durationFormat].
  /// [onActivityDurationClicked] will get called when user will click
  /// on one of activities durations displayed.
  ActivityDurationList({
    @required this.activityDurations,
    this.onActivityDurationClicked,
    Iterable<String> selectedActivities,
    this.durationFormat
  }) : this.selectedActivities = selectedActivities ?? [];

  @override
  Widget build(BuildContext context) {
    final activityDurationWidgets = activityDurations
        .map((a) => ActivityDurationItem(
          activityDuration: a,
          durationFormat: durationFormat,
          isSelected: selectedActivities.contains(a.activityName),
          onActivityDurationClicked: onActivityDurationClicked))
        .toList();
    return ListView(children: activityDurationWidgets);
  }
}

/// Displays individual [ActivityDuration] and allows selecting and de-selecting
/// it.
class ActivityDurationItem extends StatelessWidget {
  final OnActivityDurationClicked onActivityDurationClicked;
  final ActivityDuration activityDuration;
  final DurationFormat durationFormat;
  final bool isSelected;

  /// Display [activityDuration] while formatting it's duration in
  /// [durationFormat].
  /// If [isSelected] is set to true, then the activity duration will be
  /// displayed as selected.
  /// [onActivityDurationClicked] will get called if this activity duration
  /// get's clicked by the user.
  ActivityDurationItem({
    @required this.activityDuration,
    DurationFormat durationFormat,
    this.isSelected = false,
    this.onActivityDurationClicked
  }) : this.durationFormat = durationFormat ?? DurationFormat.hoursAndMinutes();

  void _handleTap() {
    if (onActivityDurationClicked != null) {
      onActivityDurationClicked(activityDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color selectedTextColor = theme.accentIconTheme.color;
    Color selectedBackgroundColor = theme.primaryColor;
    return InkWell(
        onTap: _handleTap,
        child: Container(
            color: isSelected ? selectedBackgroundColor : null,
            child: ListTile(
              title: Text(
                  activityDuration.activityName,
                  style: theme.textTheme.body1.copyWith(color: isSelected ? selectedTextColor : null)
              ),
              trailing: Text(
                durationFormat.applyTo(activityDuration.duration),
                style: theme.textTheme.body2.copyWith(color: isSelected ? selectedTextColor : theme.primaryColor),
              ),
            )
        )
    );
  }
}