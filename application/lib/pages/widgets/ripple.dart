import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  const RippleAnimation({
    Key? key,
    required this.color,
    required this.minRadius,
    required this.duration,
    this.repeat = false,
    this.child,
  }) : super(key: key);

  final Color color;
  final double minRadius;
  final Duration duration;

  final bool repeat;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    // repeating or just forwarding the animation once.
    widget.repeat ? _controller.repeat() : _controller.forward();

    return CustomPaint(
      painter: CirclePainter(
        _controller,
        widget.color,
        widget.minRadius,
      ),
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Creating circle shapes
class CirclePainter extends CustomPainter {
  CirclePainter(
    this._animation,
    this.color,
    this.minRadius,
  ) : super(repaint: _animation);

  final Color color;
  final double minRadius;
  final Animation<double> _animation;

  // animating the opacity according to min radius and waves count.
  void circle(Canvas canvas, Rect rect, double value) {
    final paintColor = color.withOpacity(1 - value);
    final radius = minRadius + rect.shortestSide / 2 * value;

    final paint = Paint()..color = paintColor;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    circle(canvas, rect, _animation.value);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}
