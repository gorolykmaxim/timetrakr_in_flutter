import 'package:flutter/material.dart';

import '../../duration.dart';
import '../../model.dart';

class ActivityDurationList extends StatelessWidget {
  final Iterable<ActivityDuration> activityDurations;
  final OnActivityDurationClicked onActivityDurationClicked;
  final Iterable<String> selectedActivities;
  final DurationFormat durationFormat;

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

typedef OnActivityDurationClicked = void Function(ActivityDuration activityDuration);

class ActivityDurationItem extends StatelessWidget {
  final OnActivityDurationClicked onActivityDurationClicked;
  final ActivityDuration activityDuration;
  final DurationFormat durationFormat;
  final bool isSelected;

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