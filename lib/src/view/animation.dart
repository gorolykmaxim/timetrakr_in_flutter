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
    return _FloatUpAnimationState();
  }
}

class _FloatUpAnimationState extends State<FloatUpAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  void _toggleAnimation() {
    if (widget.display) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    _toggleAnimation();
  }

  @override
  void didUpdateWidget(FloatUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggleAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
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
