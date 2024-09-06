import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double s;
  Color color;
  TextDirection textDirection;

  NavCustomPainter(
      double startingLoc, int itemsLength, this.color, this.textDirection) {
    final span = 1.0 / itemsLength;
    s = 0.2;
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((loc - 0.1) * size.width, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width,
        size.height * 0.05,
        loc * size.width,
        size.height * 0.60,
        (loc + s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (loc + s) * size.width,
        size.height * 0.60,
        (loc + s - s * 0.20) * size.width,
        size.height * 0.05,
        (loc + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class NavCustomClipper extends CustomClipper<Path> {
  final double deviceHeight;

  NavCustomClipper({required this.deviceHeight});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    // Adjust the path to match your curved design
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BlurredNavBar extends StatelessWidget {
  final List<Widget> items;
  final Color color;
  final Color backgroundColor;
  final TextDirection textDirection;
  final double height;
  final double? maxWidth;

  BlurredNavBar({
    required this.items,
    this.color = Colors.white,
    this.backgroundColor = Colors.blueAccent,
    this.textDirection = TextDirection.ltr,
    this.height = 75.0,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxwidth =
              min(constraints.maxWidth, maxWidth ?? constraints.maxWidth);
          return Stack(
            children: [
              // Custom ClipPath to restrict the blur to the curved shape
              ClipPath(
                clipper: NavCustomClipper(
                  deviceHeight: MediaQuery.sizeOf(context).height,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: backgroundColor.withOpacity(0.2),
                    width: maxWidth,
                    height: height,
                  ),
                ),
              ),
              // The CustomPaint with the curved shape
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: NavCustomPainter(
                    0.5, // Example startingLoc value
                    items.length,
                    color,
                    textDirection,
                  ),
                  size: Size(maxwidth, height),
                ),
              ),
              // Add other widgets here, such as your nav items
            ],
          );
        },
      ),
    );
  }
}
