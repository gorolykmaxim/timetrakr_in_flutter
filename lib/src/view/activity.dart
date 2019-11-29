import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../model.dart';
import '../query.dart';
import 'common.dart';

final defaultDateFormat = DateFormat('HH:mm');

class StartedActivitiesView extends StatefulWidget {
  final ActivityBoundedContext boundedContext;
  final ProjectionFactory projectionFactory;

  StartedActivitiesView(this.boundedContext, this.projectionFactory);

  @override
  State<StatefulWidget> createState() {
    return StartedActivitiesViewState();
  }
}

class StartedActivitiesViewState extends State<StartedActivitiesView> {
  Projection<Specification, List<StartedActivity>> todaysActivitiesProjection;


  Future<void> handleActivityStart(String name, DateTime startDate, BuildContext buildContext) async {
    try {
      await widget.boundedContext.startNewActivity(name, startDate);
    } catch (e) {
      showError(buildContext, e);
    }
  }

  Future<void> handleActivityDelete(StartedActivity startedActivity, BuildContext buildContext) async {
    try {
      await widget.boundedContext.removeActivity(startedActivity);
    } catch (e) {
      showError(buildContext, e);
    }
  }

  void handleActivityStartRequest(BuildContext context, {String activityName}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (bottomSheetContext) => StartActivityBottomSheetDialog(
          onStartActivity: (String name, DateTime startDate) => handleActivityStart(name, startDate, context),
          bottomSheetContext: bottomSheetContext,
          activityName: activityName,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StartedActivitiesListView(
          startedActivitiesStream: todaysActivitiesProjection.stream,
          onProlong: (activity, context) => handleActivityStartRequest(context, activityName: activity.name),
          onDelete: (activity, context) => handleActivityDelete(activity, context)
      ),
      floatingActionButton: StartActivityFloatingButton(onPressed: (context) {
        handleActivityStartRequest(context);
      }),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Activities')
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              title: Text('Results')
            )
          ]
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    todaysActivitiesProjection = widget.projectionFactory.findActivitiesStartedToday();
  }

  @override
  void dispose() {
    super.dispose();
    todaysActivitiesProjection.stop();
  }
}

typedef OnActivityChange = void Function(StartedActivity startedActivity, BuildContext buildContext);

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

class NoActivitiesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No activities were started today'));
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
            onTap: () => onProlong(startedActivity, context),
          )
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete_forever,
            onTap: () => onDelete(startedActivity, context),
          )
        ],
    );
  }
}

typedef OnActivityStartRequested = void Function(BuildContext context);

class StartActivityFloatingButton extends StatelessWidget {
  final OnActivityStartRequested onPressed;

  StartActivityFloatingButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () => onPressed(context),
        tooltip: 'Start new activity',
        child: Icon(Icons.add)
    );
  }
}

typedef OnStartActivity = void Function(String name, DateTime startDate);

class StartActivityBottomSheetDialog extends StatefulWidget {
  final OnStartActivity onStartActivity;
  final String activityName;
  final BuildContext bottomSheetContext;

  StartActivityBottomSheetDialog({this.onStartActivity, this.activityName, @required this.bottomSheetContext});

  @override
  State<StatefulWidget> createState() {
    return StartActivityBottomSheetDialogState();
  }
}

class StartActivityBottomSheetDialogState extends State<StartActivityBottomSheetDialog> {
  final double padding = 15;
  String activityName;
  DateTime startDate;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    activityName = widget.activityName ?? '';
    controller.text = activityName;
    startDate = DateTime.now();
  }

  void startActivity() {
    if (widget.onStartActivity != null && activityName.isNotEmpty) {
      Navigator.pop(widget.bottomSheetContext);
      widget.onStartActivity(activityName, startDate);
    }
  }

  void setActivityName(String name) {
    activityName = name;
  }

  Future<void> handleTimeChange(BuildContext context) async {
    var time = TimeOfDay.fromDateTime(startDate);
    time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDate),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child
          );
        }
    );
    if (time != null) {
      startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          time.hour,
          time.minute
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              top: padding,
              left: padding,
              right: padding,
              bottom: MediaQuery.of(context).viewInsets.bottom + padding
          ),
          child: Column(
            children: <Widget>[
              TextField(
                  controller: controller,
                  decoration: InputDecoration.collapsed(
                      hintText: 'What task are you working on?'
                  ),
                  onChanged: setActivityName,
                  onSubmitted: (_) => startActivity(),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                        child: Text(
                          'since ${defaultDateFormat.format(startDate)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () => handleTimeChange(context),
                    ),
                    RaisedButton(
                        onPressed: startActivity,
                        child: Text('START')
                    )
                  ]
              )
            ],
          ),
        )
    );
  }
}