import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shape_model.dart';
import '../services/audio_service.dart';

/// Outline-tracing activity. Reuses the same pixel-comparison validation
/// approach as حروفي's letter tracing: the child's finger strokes are
/// rasterized and compared against the shape's outline mask.
class ShapeTraceWidget extends StatefulWidget {
  final Shape3DType shapeType;
  final String shapeNameArabic;
  final double canvasSize;
  final double matchThreshold; // 0..1, % of outline pixels that must be covered
  final void Function(bool passed) onComplete;

  const ShapeTraceWidget({
    super.key,
    required this.shapeType,
    required this.shapeNameArabic,
    required this.onComplete,
    this.canvasSize = 280,
    this.matchThreshold = 0.65,
  });

  @override
  State<ShapeTraceWidget> createState() => _ShapeTraceWidgetState();
}

class _ShapeTraceWidgetState extends State<ShapeTraceWidget> {
  final List<Offset> _userPoints = [];
  final GlobalKey _repaintKey = GlobalKey();
  bool _evaluated = false;

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    setState(() {
      _userPoints.add(box.globalToLocal(details.globalPosition));
    });
  }

  Future<void> _evaluate() async {
    if (_evaluated || _userPoints.length < 10) return;
    _evaluated = true;

    // Rasterize both the outline mask and the user's stroke path, then
    // compare coverage - same pixel-comparison technique as حروفي.
    final outlineMask = _OutlineMaskGenerator.generate(
      widget.shapeType,
      Size(widget.canvasSize, widget.canvasSize),
    );
    final coverage = _computeCoverage(outlineMask, _userPoints, widget.canvasSize);

    final passed = coverage >= widget.matchThreshold;
    if (passed) {
      await AudioService.instance.playSuccess();
    } else {
      await AudioService.instance.playError();
    }
    widget.onComplete(passed);
  }

  double _computeCoverage(List<Offset> maskPoints, List<Offset> userPoints, double size) {
    if (maskPoints.isEmpty) return 0;
    const hitRadius = 18.0;
    int hits = 0;
    for (final maskPt in maskPoints) {
      final covered = userPoints.any((up) => (up - maskPt).distance <= hitRadius);
      if (covered) hits++;
    }
    return hits / maskPoints.length;
  }

  void _reset() {
    setState(() {
      _userPoints.clear();
      _evaluated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('تتبع شكل ${widget.shapeNameArabic}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) => _evaluate(),
          child: RepaintBoundary(
            key: _repaintKey,
            child: CustomPaint(
              size: Size(widget.canvasSize, widget.canvasSize),
              painter: _TraceCanvasPainter(
                shapeType: widget.shapeType,
                userPoints: _userPoints,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}

class _TraceCanvasPainter extends CustomPainter {
  final Shape3DType shapeType;
  final List<Offset> userPoints;

  _TraceCanvasPainter({required this.shapeType, required this.userPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed outline guide.
    final guidePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final outline = _OutlineMaskGenerator.outlinePath(shapeType, size);
    canvas.drawPath(outline, guidePaint);

    // User's traced stroke.
    if (userPoints.length > 1) {
      final userPaint = Paint()
        ..color = Colors.deepOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(userPoints.first.dx, userPoints.first.dy);
      for (final p in userPoints.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, userPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TraceCanvasPainter oldDelegate) => true;
}

/// Generates a simplified 2D outline mask/path per shape for tracing +
/// coverage validation (separate from the 3D painter used elsewhere).
class _OutlineMaskGenerator {
  static Path outlinePath(Shape3DType type, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.75;
    switch (type) {
      case Shape3DType.sphere:
      case Shape3DType.ellipsoid:
        return Path()..addOval(Rect.fromCenter(center: c, width: r * 2, height: r * 1.7));
      case Shape3DType.cube:
        return Path()..addRect(Rect.fromCenter(center: c, width: r * 1.6, height: r * 1.6));
      case Shape3DType.cuboid:
        return Path()..addRect(Rect.fromCenter(center: c, width: r * 2, height: r * 1.2));
      case Shape3DType.pyramid:
        return Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx - r, c.dy + r * 0.7)
          ..lineTo(c.dx + r, c.dy + r * 0.7)
          ..close();
      case Shape3DType.star3d:
        return _polygonPath(c, r, 5, star: true);
      case Shape3DType.heart3d:
        final path = Path();
        path.moveTo(c.dx, c.dy + r * 0.8);
        path.cubicTo(c.dx - r * 1.4, c.dy - r * 0.2, c.dx - r * 0.5, c.dy - r * 1.2, c.dx, c.dy - r * 0.4);
        path.cubicTo(c.dx + r * 0.5, c.dy - r * 1.2, c.dx + r * 1.4, c.dy - r * 0.2, c.dx, c.dy + r * 0.8);
        path.close();
        return path;
      case Shape3DType.rhombus3d:
        return _polygonPath(c, r, 4, rotationOffset: 0);
      case Shape3DType.pentagonPrism:
        return _polygonPath(c, r, 5);
      case Shape3DType.hexagonPrism:
        return _polygonPath(c, r, 6);
    }
  }

  /// Sampled points along the outline path, used for coverage scoring.
  static List<Offset> generate(Shape3DType type, Size size) {
    final path = outlinePath(type, size);
    final metrics = path.computeMetrics();
    final points = <Offset>[];
    for (final metric in metrics) {
      final steps = 60;
      for (int i = 0; i < steps; i++) {
        final dist = metric.length * (i / steps);
        final tangent = metric.getTangentForOffset(dist);
        if (tangent != null) points.add(tangent.position);
      }
    }
    return points;
  }

  static Path _polygonPath(Offset center, double r, int sides,
      {bool star = false, double rotationOffset = -math.pi / 2}) {
    final path = Path();
    final count = star ? sides * 2 : sides;
    for (int i = 0; i < count; i++) {
      final a = rotationOffset + (2 * math.pi * i / count);
      final radius = star && i.isOdd ? r * 0.45 : r;
      final pt = Offset(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    return path;
  }
}
