import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../widgets/shape_trace_widget.dart';

class TraceActivity extends StatelessWidget {
  final String shapeId;
  final void Function(bool passed) onResult;
  const TraceActivity({super.key, required this.shapeId, required this.onResult});

  @override
  Widget build(BuildContext context) {
    final meta = shapeById(shapeId);
    return ShapeTraceWidget(
      shapeType: meta.renderType,
      shapeNameArabic: meta.nameArabic,
      onComplete: onResult,
    );
  }
}
