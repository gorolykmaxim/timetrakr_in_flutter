import 'package:flutter/material.dart';
import 'package:flutter_commons/flutter_commons.dart';
import 'package:intl/intl.dart';

typedef OnStartActivity = void Function(String name, DateTime startDate);

class StartActivityBottomSheetDialog extends StatefulWidget {
  final OnStartActivity onStartActivity;
  final String activityName;
  final DateTime startDate;
  final DateFormat dateFormat;

  StartActivityBottomSheetDialog({
    this.onStartActivity,
    this.activityName,
    @required this.startDate,
    DateFormat dateFormat
  }) : this.dateFormat = dateFormat ?? DateFormat();

  @override
  State<StatefulWidget> createState() {
    return StartActivityBottomSheetDialogState();
  }
}

class StartActivityBottomSheetDialogState extends State<StartActivityBottomSheetDialog> {
  DateTime startDate;
  TextEditingController controller = TextEditingController();
  InjectableDialogContainer dialogContainer = InjectableDialogContainer();

  void initialize(StartActivityBottomSheetDialog widget) {
    if (widget.activityName != null) {
      controller.text = widget.activityName;
    }
    startDate = widget.startDate;
  }

  void startActivity(StartActivityBottomSheetDialog widget, NavigatorState navigatorState) {
    if (widget.onStartActivity != null && controller.text.isNotEmpty) {
      navigatorState.pop();
      widget.onStartActivity(controller.text, startDate);
    }
  }

  Future<void> handleTimeChange(State state, BuildContext context) async {
    var time = TimeOfDay.fromDateTime(startDate);
    time = await dialogContainer.showTimePicker(
        context: context,
        initialTime: time,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child
          );
        }
    );
    if (time != null) {
      state.setState(() {
        startDate = DateTime(startDate.year, startDate.month, startDate.day, time.hour, time.minute);
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
    const padding = 15.0;
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