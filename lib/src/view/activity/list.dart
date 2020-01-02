import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:emptiable_list/emptiable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../model.dart';

typedef OnActivityChange = void Function(StartedActivity startedActivity);

class StartedActivitiesListView extends StatelessWidget {
  final Stream<List<StartedActivity>> startedActivitiesStream;
  final OnActivityChange onProlong, onDelete;
  final DateFormat dateFormat;
  final SlidableController slidableController = SlidableController();

  StartedActivitiesListView({
    @required this.startedActivitiesStream,
    @required this.onProlong,
    @required this.onDelete,
    this.dateFormat
  });

  Widget _buildItem(StartedActivity activity, int index, BuildContext context, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: StartedActivityListItem(
          startedActivity: activity,
          onProlong: onProlong,
          onDelete: onDelete,
          dateFormat: dateFormat,
          controller: slidableController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmptiableList(
        listStream: startedActivitiesStream,
        list: Card(
          child: AnimatedStreamList(
              shrinkWrap: true,
              streamList: startedActivitiesStream,
              itemBuilder: _buildItem,
              itemRemovedBuilder: _buildItem
          )
        ),
        placeholder: NoStartedActivities());
  }
}

class NoStartedActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
            'To start a new activity, press that green button down below',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline
        )
    );
  }
}

class StartedActivityListItem extends StatelessWidget {
  final DateFormat dateFormat;
  final StartedActivity startedActivity;
  final OnActivityChange onProlong, onDelete;
  final SlidableController controller;

  StartedActivityListItem({
    @required this.startedActivity,
    @required this.onProlong,
    @required this.onDelete,
    DateFormat dateFormat,
    this.controller
  }): this.dateFormat = dateFormat ?? DateFormat();

  @override
  Widget build(BuildContext context) {
    return Slidable(
      controller: controller,
      child: Material(
        child: ListTile(
          title: Text(startedActivity.name),
          subtitle: Text('since ${dateFormat.format(startedActivity.startDate)}'),
        ),
      ),
      actionPane: SlidableBehindActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Prolong',
          color: Colors.green,
          icon: Icons.refresh,
          onTap: () => onProlong(startedActivity),
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete_forever,
          onTap: () => onDelete(startedActivity),
        )
      ],
    );
  }
}