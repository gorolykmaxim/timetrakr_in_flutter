import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:mockito/mockito.dart';

class SimpleCollectionMock<T> extends Mock implements SimpleCollection<T> {}

class EventStreamMock<T> extends Mock implements EventStream<T> {}