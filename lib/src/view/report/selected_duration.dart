import 'package:flutter/material.dart';

import '../../duration.dart';

class SelectedDuration extends StatelessWidget {
  final Duration totalDuration;
  final Function onRemoveSelection;
  final DurationFormat durationFormat;

  SelectedDuration({
    @required this.totalDuration,
    this.onRemoveSelection,
    DurationFormat durationFormat})
      : this.durationFormat = durationFormat ?? DurationFormat.hoursAndMinutes();

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: ListTile(
          title: Text('Total duration: ${durationFormat.applyTo(totalDuration)}'),
          trailing: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
              tooltip: 'Clear selection',
              onPressed: onRemoveSelection
          ),
        )
    );
  }
}