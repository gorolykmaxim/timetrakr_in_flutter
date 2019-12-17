import 'package:flutter_event_projections/flutter_event_projections.dart';
import 'package:flutter_repository/flutter_repository.dart';
import 'package:mockito/mockito.dart';

class SimpleCollectionMock<T> extends Mock implements SimpleCollection<T> {}

class ObservableEventStreamMock<T> extends Mock implements ObservableEventStream<T> {}