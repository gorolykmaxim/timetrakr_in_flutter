import 'package:flutter/widgets.dart';
import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/query.dart';

class SimpleCollectionMock<T> extends Mock implements SimpleCollection<T> {}

class ObservableEventStreamMock<T> extends Mock implements ObservableEventStream<T> {}

class ProjectionFactoryMock extends Mock implements ProjectionFactory {}

class ProjectionMock<T, D> extends Mock implements Projection<T, D> {}

class StateDouble extends State {
  @override
  Widget build(BuildContext context) {
    return null;
  }

  @override
  void setState(VoidCallback fn) {
    fn();
  }
}

abstract class DiagnosticableMixinFriendlyMock extends Mock {
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.debug });
}