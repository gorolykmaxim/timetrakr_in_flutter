import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:emptiable_list/emptiable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../model.dart';

/// Callback, that will be called when user tries to perform some action
/// on an existing [startedActivity].
typedef OnActivityChange = void Function(StartedActivity startedActivity);

/// Displays list of [StartedActivity]s and allows interacting with items
/// in it.
class StartedActivitiesListView extends StatelessWidget {
  final Stream<List<StartedActivity>> startedActivitiesStream;
  final OnActivityChange onProlong, onDelete;
  final DateFormat dateFormat;
  final SlidableController slidableController = SlidableController();

  /// Create a list of started activities, that will display activities,
  /// coming from [startedActivitiesStream].
  /// When a user will try to prolong an activity, displayed in the list -
  /// [onProlong] will get called.
  /// When a user will try to delete an activity, displayed in the list -
  /// [onDelete] will get called.
  /// Start date of activities, displayed in this list will be formatted
  /// using [dateFormat].
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

/// A placeholder, that will be displayed in place of a list of started
/// activities, if there are no activities to display.
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

/// Displays a single [StartedActivity] in the [StartedActivitiesListView] and
/// allows interacting with it.
class StartedActivityListItem extends StatelessWidget {
  final DateFormat dateFormat;
  final StartedActivity startedActivity;
  final OnActivityChange onProlong, onDelete;
  final SlidableController controller;

  /// Create started activity list item for [startedActivity].
  /// [onProlong] will get called if user will try to prolong this activity.
  /// [onDelete] will get called if user will try to delete this activity.
  /// Activity's start date will be displayed in [dateFormat].
  /// A single instance of [controller] is used across all
  /// [StartedActivityListItem]s to make sure that there can be always only on
  /// [Slidable] active.
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