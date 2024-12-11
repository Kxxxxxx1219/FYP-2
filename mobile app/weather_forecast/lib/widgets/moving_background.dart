import 'package:flutter/material.dart';
import 'dart:math';

class MovingBackground extends StatefulWidget {
  final Widget child; // Child widget to display on top of the background

  MovingBackground({required this.child}); // Constructor

  @override
  _MovingBackgroundState createState() => _MovingBackgroundState();
}

class _MovingBackgroundState extends State<MovingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 8), // Duration for one animation cycle
      vsync: this,
    )..repeat(reverse: true); // Repeat animation in reverse for smooth effect

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut)); // Optional curve for a smoother animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate gradient stops and ensure they stay between 0.0 and 1.0
        double stop1 = _animation.value;
        double stop2 =
            min(_animation.value + 0.3, 1.0); // Ensure stops do not exceed 1.0
        double stop3 =
            min(_animation.value + 0.6, 1.0); // Ensure stops do not exceed 1.0

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade300.withOpacity(0.8),
                Colors.yellow.shade400.withOpacity(0.8),
                Colors.blue.shade900.withOpacity(0.8),
              ],
              stops: [
                stop1,
                stop2,
                stop3,
              ],
              tileMode: TileMode
                  .mirror, // Creates a mirrored effect for smooth transitions
            ),
          ),
          child:
              widget.child, // Display the child widget on top of the background
        );
      },
    );
  }
}
