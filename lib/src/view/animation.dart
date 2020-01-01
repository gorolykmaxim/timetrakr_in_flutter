import 'package:flutter/material.dart';

class FloatUpAnimation extends StatefulWidget {
  final Widget child;
  final bool display;
  final Duration duration;

  FloatUpAnimation({
    @required this.child,
    this.display = false,
    Duration duration
  }) : this.duration = duration ?? const Duration(milliseconds: 400);

  @override
  State<StatefulWidget> createState() {
    return FloatUpAnimationState();
  }
}

class FloatUpAnimationState extends State<FloatUpAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  void initialize(FloatUpAnimation widget) {
    controller = AnimationController(vsync: this, duration: widget.duration);
    toggleAnimation(widget);
  }

  void destroy() {
    controller.dispose();
  }

  void toggleAnimation(FloatUpAnimation widget) {
    if (widget.display) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void initState() {
    initialize(widget);
  }

  @override
  void didUpdateWidget(FloatUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    toggleAnimation(widget);
  }

  @override
  void dispose() {
    destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn
      ),
      child: widget.child,
    );
  }
}
