import 'dart:async';

import 'package:flutter/material.dart';

const EMPTY_WIDGET = SizedBox.shrink();
const DEFAULT_DURATION = const Duration(milliseconds: 500);

class ListThatCanBeEmpty extends StatefulWidget {
  final Widget placeholder;
  final Widget list;
  final Stream<List> listStream;
  final Duration transitionDuration;

  ListThatCanBeEmpty({@required this.listStream, Widget placeholder = EMPTY_WIDGET, @required this.list, Duration transitionDuration = DEFAULT_DURATION}):
    this.placeholder = placeholder,
    this.transitionDuration = transitionDuration;

  @override
  State<StatefulWidget> createState() {
    return _ListThatCanBeEmptyState();
  }
}

class _ListThatCanBeEmptyState extends State<ListThatCanBeEmpty> {
  StreamSubscription subscription;
  List currentList;

  @override
  void initState() {
    subscription = widget.listStream.listen((list) {
      setState(() {
        currentList = list;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    subscription = null;
    currentList = null;
  }

  @override
  Widget build(BuildContext context) {
    final listIsEmpty = currentList == null || currentList.isEmpty;
    return Stack(
      children: <Widget>[
        AnimatedOpacity(opacity: listIsEmpty ? 1 : 0, duration: widget.transitionDuration, child: widget.placeholder),
        AnimatedOpacity(opacity: listIsEmpty ? 0 : 1, duration: widget.transitionDuration, child: widget.list)
      ],
    );
  }
}