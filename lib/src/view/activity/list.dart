import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model.dart';
import '../common.dart';

typedef OnActivityChange = void Function(StartedActivity startedActivity);

class StartedActivitiesListView extends StatelessWidget {
  final Stream<List<StartedActivity>> startedActivitiesStream;
  final OnActivityChange onProlong, onDelete;

  StartedActivitiesListView({@required this.startedActivitiesStream, @required this.onProlong, @required this.onDelete});

  Widget buildItem(StartedActivity activity, int index, BuildContext context, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: StartedActivityListItem(
          startedActivity: activity,
          onProlong: onProlong,
          onDelete: onDelete
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade200,
        child: AnimatedStreamList(
            streamList: startedActivitiesStream,
            itemBuilder: buildItem,
            itemRemovedBuilder: buildItem
        )
    );
  }
}

class StartedActivityListItem extends StatelessWidget {
  final StartedActivity startedActivity;
  final OnActivityChange onProlong, onDelete;

  StartedActivityListItem({@required this.startedActivity, @required this.onProlong, @required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: Text(startedActivity.name),
          subtitle: Text('since ${defaultDateFormat.format(startedActivity.startDate)}'),
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