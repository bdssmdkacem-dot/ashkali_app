import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shape_3d_widget.dart';

/// Drag-and-drop sort - reuses أرقامي's drag-drop base pattern.
/// Presents one shape at a time; child drags it into the matching bin
/// among 2-3 bins (mixes previously-learned shapes for spaced repetition).
class SortActivity extends StatefulWidget {
  final List<String> shapeIds; // pool to draw bins/targets from
  final void Function(bool passed) onResult;
  const SortActivity({super.key, required this.shapeIds, required this.onResult});

  @override
  State<SortActivity> createState() => _SortActivityState();
}

class _SortActivityState extends State<SortActivity> {
  late final String _targetId;
  late final List<String> _binIds;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    final pool = List<String>.from(widget.shapeIds)..shuffle();
    _targetId = pool.first;
    final others = pool.skip(1).take(2).toList();
    _binIds = [_targetId, ...others]..shuffle();
  }

  void _onAccept(String binId) {
    final passed = binId == _targetId;
    if (passed) {
      AudioService.instance.playSuccess();
    } else {
      AudioService.instance.playError();
    }
    widget.onResult(passed);
  }

  @override
  Widget build(BuildContext context) {
    final targetMeta = shapeById(_targetId);
    final targetColor = AppColors.shapeColors[targetMeta.id] ?? AppColors.teal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('اسحب الشكل إلى الصندوق الصحيح', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        Draggable<String>(
          data: _targetId,
          feedback: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 100, autoRotate: false),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 120),
          ),
          child: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 120),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _binIds.map((binId) {
            final meta = shapeById(binId);
            return DragTarget<String>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) => _onAccept(binId),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: candidateData.isNotEmpty ? Colors.grey.shade200 : null,
                  ),
                  child: Center(child: Text(meta.nameArabic, style: const TextStyle(fontSize: 14))),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
