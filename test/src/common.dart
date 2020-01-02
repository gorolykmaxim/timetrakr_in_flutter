import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/query.dart';

class ObservableEventStreamMock<T> extends Mock implements ObservableEventStream<T> {}

class ProjectionFactoryMock extends Mock implements ProjectionFactory {}

class ProjectionMock<T, D> extends Mock implements Projection<T, D> {}