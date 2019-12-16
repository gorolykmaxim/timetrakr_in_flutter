import 'package:flutter/material.dart';

import '../../duration.dart';

class SelectedDuration extends StatelessWidget {
  final Duration totalDuration;
  final Function onRemoveSelection;
  final DurationFormatter durationFormatter;

  SelectedDuration({
    @required this.totalDuration,
    this.onRemoveSelection,
    DurationFormatter durationFormatter})
      : this.durationFormatter = durationFormatter ?? DurationFormatter.hoursAndMinutes();

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: ListTile(
          title: Text('Total duration: ${durationFormatter.format(totalDuration)}'),
          trailing: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
              tooltip: 'Clear selection',
              onPressed: onRemoveSelection
          ),
        )
    );
  }
}