import 'package:flutter/material.dart';

const EMPTY_WIDGET = SizedBox.shrink();

AsyncWidgetBuilder<T> makeBuilder<T>(Widget dataWidget(T data), {Widget errorWidget(Object error), Widget loadingWidget()}) {
  if (errorWidget == null) {
    errorWidget = (error) => EMPTY_WIDGET;
  }
  if (loadingWidget == null) {
    loadingWidget = () => EMPTY_WIDGET;
  }
  return (BuildContext context, AsyncSnapshot<T>  snapshot) {
    if (snapshot.hasError) {
      return errorWidget(snapshot.error);
    } else if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
      return dataWidget(snapshot.data);
    } else {
      return loadingWidget();
    }
  };
}

class ListViewWithPlaceholder extends StatelessWidget {
  final List<Widget> children;
  final Widget listPlaceholder;

  ListViewWithPlaceholder({@required List<Widget> children, @required Widget listPlaceholder}):
        this.children = children,
        this.listPlaceholder = listPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return listPlaceholder;
    } else {
      return ListView(children: children);
    }
  }
}

void showError(BuildContext buildContext, Object error) {
  Scaffold.of(buildContext).showSnackBar(SnackBar(content: Text(error.toString()), duration: Duration(seconds: 3)));
}