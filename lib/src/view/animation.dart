import 'package:flutter/material.dart';

class FloatUpAnimation extends StatefulWidget {
  final Widget child;
  final bool display;

  FloatUpAnimation({@required this.child, this.display = false});

  @override
  State<StatefulWidget> createState() {
    return _FloatUpAnimationState();
  }
}

class _FloatUpAnimationState extends State<FloatUpAnimation> with SingleTickerProviderStateMixin {
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
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _toggleAnimation();
  }

  @override
  void didUpdateWidget(FloatUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggleAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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