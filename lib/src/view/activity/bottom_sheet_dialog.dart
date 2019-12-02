import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef OnStartActivity = void Function(String name, DateTime startDate);

class StartActivityBottomSheetDialog extends StatefulWidget {
  final OnStartActivity onStartActivity;
  final String activityName;
  final BuildContext bottomSheetContext;
  final DateFormat dateFormat;

  StartActivityBottomSheetDialog({this.onStartActivity, this.activityName, @required this.bottomSheetContext, DateFormat dateFormat}):
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
      setState(() {
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
                        'since ${widget.dateFormat.format(startDate)}',
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