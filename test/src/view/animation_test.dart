import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timetrakr_in_flutter/src/view/animation.dart';

class AnimationControllerMock extends Mock implements AnimationController {}

void main() {
  group('FloatUpAnimationState', () {
    AnimationController controller;
    FloatUpAnimation widget;
    FloatUpAnimationState state;
    setUp(() {
      controller = AnimationControllerMock();
      widget = FloatUpAnimation(child: null);
      state = widget.createState();
      state.controller = controller;
    });
    test('displays float-up animation when initialized and parent widget '
        'should be displayed', () {
      // given
      widget = FloatUpAnimation(child: null, display: true);
      // when
      state.initialize(widget);
      // then
      verify(controller.forward());
    });
    test('displays float-down animation when initialized and parent widget '
        'should not be displayed', () {
      // when
      state.initialize(widget);
      // then
      verify(controller.reverse());
    });
    test('disposes animation controller on dispose', () {
      // when
      state.destroy();
      // then
      verify(controller.dispose());
    });
    test('displays float-up animation on demand if parent widget should be '
        'displayed', () {
      // given
      widget = FloatUpAnimation(child: null, display: true);
      // when
      state.toggleAnimation(widget);
      // then
      verify(controller.forward());
    });
    test('displays float-down animation on demand if parent widget should not be '
        'displayed', () {
      // when
      state.toggleAnimation(widget);
      // then
      verify(controller.reverse());
    });
  });
}