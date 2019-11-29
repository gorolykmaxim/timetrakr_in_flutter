import 'package:flutter/material.dart';

import '../model.dart';
import '../query.dart';
import 'activity.dart';

class TimeTrakrApp extends StatelessWidget {
  final ActivityBoundedContext boundedContext;
  final ProjectionFactory projectionFactory;

  TimeTrakrApp(this.boundedContext, this.projectionFactory);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Trakr',
      theme: ThemeData(
          primarySwatch: Colors.green,
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.green,
              textTheme: ButtonTextTheme.primary
          )
      ),
      home: StartedActivitiesView(boundedContext, projectionFactory),
    );
  }
}