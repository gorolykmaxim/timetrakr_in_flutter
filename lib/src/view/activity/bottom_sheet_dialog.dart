import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef OnStartActivity = void Function(String name, DateTime startDate);

class StartActivityBottomSheetDialog extends StatefulWidget {
  final OnStartActivity onStartActivity;
  final String activityName;
  final BuildContext bottomSheetContext;
  final DateTime startDate;
  final DateFormat dateFormat;

  StartActivityBottomSheetDialog({this.onStartActivity, this.activityName, @required this.bottomSheetContext, @required this.startDate, DateFormat dateFormat}):
        this.dateFormat = dateFormat ?? DateFormat();

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

  void initialize(StartActivityBottomSheetDialog widget) {
    activityName = widget.activityName ?? '';
    controller.text = activityName;
    startDate = widget.startDate;
  }

  void startActivity(StartActivityBottomSheetDialog widget, NavigatorState navigatorState) {
    if (widget.onStartActivity != null && activityName.isNotEmpty) {
      navigatorState.pop();
      widget.onStartActivity(activityName, startDate);
    }
  }

  void setActivityName(String name) {
    activityName = name;
  }

  Future<void> handleTimeChange(State state, BuildContext context) async {
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
      state.setState(() {
        startDate = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            time.hour,
            time.minute
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialize(widget);
  }

  @override
  Widget build(BuildContext context) {
    final navigatorState = Navigator.of(context);
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
                onChanged: (name) => setActivityName(name),
                onSubmitted: (_) => startActivity(widget, navigatorState),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        'since ${widget.dateFormat.format(startDate)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () => handleTimeChange(this, context),
                    ),
                    RaisedButton(
                        onPressed: () => startActivity(widget, navigatorState),
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