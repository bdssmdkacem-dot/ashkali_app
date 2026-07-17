import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shape_model.dart';

/// Renders a shape with a pseudo-3D look (extrusion + shading + slow
/// rotation) purely via CustomPainter - no external 3D model assets,
/// keeping consistent with the series' "no external dependencies" rule.
class Shape3DWidget extends StatefulWidget {
  final Shape3DType type;
  final Color color;
  final double size;
  final bool autoRotate;

  const Shape3DWidget({
    super.key,
    required this.type,
    required this.color,
    this.size = 180,
    this.autoRotate = true,
  });

  @override
  State<Shape3DWidget> createState() => _Shape3DWidgetState();
}

class _Shape3DWidgetState extends State<Shape3DWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = widget.autoRotate ? _controller.value * 2 * math.pi : 0.0;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _Shape3DPainter(
            type: widget.type,
            color: widget.color,
            angle: angle,
          ),
        );
      },
    );
  }
}

class _Shape3DPainter extends CustomPainter {
  final Shape3DType type;
  final Color color;
  final double angle; // 0..2pi, drives the fake-3D rotation/shading

  _Shape3DPainter({required this.type, required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.75;

    // "Depth" factor from the rotation angle - squashes horizontally
    // and shifts a highlight to simulate a light source orbiting the shape.
    final depth = math.cos(angle); // -1..1
    final squashX = 0.55 + 0.45 * depth.abs();
    final highlightOffset = Offset(depth * r * 0.3, -r * 0.3);

    final topColor = _lighten(color, 0.35);
    final baseColor = color;
    final shadowColor = _darken(color, 0.35);

    switch (type) {
      case Shape3DType.sphere:
        _paintSphere(canvas, center, r, topColor, baseColor, highlightOffset);
        break;
      case Shape3DType.cube:
        _paintCuboid(canvas, center, r, r, squashX, topColor, baseColor, shadowColor);
        break;
      case Shape3DType.cuboid:
        _paintCuboid(canvas, center, r * 1.3, r * 0.7, squashX, topColor, baseColor, shadowColor);
        break;
      case Shape3DType.pyramid:
        _paintPyramid(canvas, center, r, topColor, baseColor, shadowColor);
        break;
      case Shape3DType.ellipsoid:
        _paintSphere(canvas, center, r, topColor, baseColor, highlightOffset,
            xScale: 1.3, yScale: 0.85);
        break;
      case Shape3DType.star3d:
        _paintExtrudedPolygon(canvas, center, r, 5, topColor, baseColor, shadowColor,
            star: true);
        break;
      case Shape3DType.heart3d:
        _paintHeart(canvas, center, r, topColor, baseColor, shadowColor);
        break;
      case Shape3DType.rhombus3d:
        _paintExtrudedPolygon(canvas, center, r, 4, topColor, baseColor, shadowColor,
            rotationOffset: math.pi / 4);
        break;
      case Shape3DType.pentagonPrism:
        _paintExtrudedPolygon(canvas, center, r, 5, topColor, baseColor, shadowColor);
        break;
      case Shape3DType.hexagonPrism:
        _paintExtrudedPolygon(canvas, center, r, 6, topColor, baseColor, shadowColor);
        break;
    }
  }

  void _paintSphere(Canvas canvas, Offset center, double r, Color top, Color base,
      Offset highlightOffset, {double xScale = 1, double yScale = 1}) {
    final rect = Rect.fromCenter(center: center, width: r * 2 * xScale, height: r * 2 * yScale);
    final gradient = RadialGradient(
      center: Alignment(highlightOffset.dx / r, highlightOffset.dy / r),
      radius: 0.9,
      colors: [top, base, _darken(base, 0.3)],
      stops: const [0.0, 0.6, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawOval(rect, paint);
  }

  void _paintCuboid(Canvas canvas, Offset center, double halfW, double halfH,
      double squashX, Color top, Color base, Color shadow) {
    final depthOffset = Offset(12 * squashX, -12);
    final frontRect = Rect.fromCenter(
        center: center, width: halfW * 2 * squashX, height: halfH * 2);

    final topFace = Path()
      ..moveTo(frontRect.left, frontRect.top)
      ..lineTo(frontRect.left + depthOffset.dx, frontRect.top + depthOffset.dy)
      ..lineTo(frontRect.right + depthOffset.dx, frontRect.top + depthOffset.dy)
      ..lineTo(frontRect.right, frontRect.top)
      ..close();

    final sideFace = Path()
      ..moveTo(frontRect.right, frontRect.top)
      ..lineTo(frontRect.right + depthOffset.dx, frontRect.top + depthOffset.dy)
      ..lineTo(frontRect.right + depthOffset.dx, frontRect.bottom + depthOffset.dy)
      ..lineTo(frontRect.right, frontRect.bottom)
      ..close();

    canvas.drawPath(sideFace, Paint()..color = shadow);
    canvas.drawPath(topFace, Paint()..color = top);
    canvas.drawRect(frontRect, Paint()..color = base);

    final strokePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(frontRect, strokePaint);
    canvas.drawPath(topFace, strokePaint);
    canvas.drawPath(sideFace, strokePaint);
  }

  void _paintPyramid(Canvas canvas, Offset center, double r, Color top, Color base, Color shadow) {
    final apex = Offset(center.dx, center.dy - r);
    final baseLeft = Offset(center.dx - r, center.dy + r * 0.6);
    final baseRight = Offset(center.dx + r, center.dy + r * 0.6);
    final baseBack = Offset(center.dx, center.dy + r * 0.9);

    final leftFace = Path()..moveTo(apex.dx, apex.dy)..lineTo(baseLeft.dx, baseLeft.dy)..lineTo(baseBack.dx, baseBack.dy)..close();
    final rightFace = Path()..moveTo(apex.dx, apex.dy)..lineTo(baseBack.dx, baseBack.dy)..lineTo(baseRight.dx, baseRight.dy)..close();

    canvas.drawPath(leftFace, Paint()..color = shadow);
    canvas.drawPath(rightFace, Paint()..color = base);

    final strokePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(leftFace, strokePaint);
    canvas.drawPath(rightFace, strokePaint);
  }

  void _paintExtrudedPolygon(Canvas canvas, Offset center, double r, int sides,
      Color top, Color base, Color shadow,
      {bool star = false, double rotationOffset = -math.pi / 2}) {
    final depth = Offset(0, 14.0);
    final frontPoints = _polygonPoints(center, r, sides, rotationOffset, star: star);
    final backPoints = frontPoints.map((p) => p + depth).toList();

    // Side "walls" between each consecutive front/back point pair.
    for (int i = 0; i < frontPoints.length; i++) {
      final next = (i + 1) % frontPoints.length;
      final wall = Path()
        ..moveTo(frontPoints[i].dx, frontPoints[i].dy)
        ..lineTo(frontPoints[next].dx, frontPoints[next].dy)
        ..lineTo(backPoints[next].dx, backPoints[next].dy)
        ..lineTo(backPoints[i].dx, backPoints[i].dy)
        ..close();
      canvas.drawPath(wall, Paint()..color = shadow);
    }

    final frontPath = Path()..addPolygon(frontPoints, true);
    canvas.drawPath(frontPath, Paint()..color = base);
    final strokePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(frontPath, strokePaint);
  }

  List<Offset> _polygonPoints(Offset center, double r, int sides, double rotationOffset,
      {bool star = false}) {
    final points = <Offset>[];
    final count = star ? sides * 2 : sides;
    for (int i = 0; i < count; i++) {
      final a = rotationOffset + (2 * math.pi * i / count);
      final radius = star && i.isOdd ? r * 0.45 : r;
      points.add(Offset(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a)));
    }
    return points;
  }

  void _paintHeart(Canvas canvas, Offset center, double r, Color top, Color base, Color shadow) {
    final path = Path();
    path.moveTo(center.dx, center.dy + r * 0.8);
    path.cubicTo(center.dx - r * 1.4, center.dy - r * 0.2, center.dx - r * 0.5,
        center.dy - r * 1.2, center.dx, center.dy - r * 0.4);
    path.cubicTo(center.dx + r * 0.5, center.dy - r * 1.2, center.dx + r * 1.4,
        center.dy - r * 0.2, center.dx, center.dy + r * 0.8);
    path.close();

    final rect = Rect.fromCenter(center: center, width: r * 2.6, height: r * 2.2);
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.0,
      colors: [top, base, shadow],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawPath(path, Paint()..shader = gradient.createShader(rect));
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _Shape3DPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color || oldDelegate.type != type;
}
