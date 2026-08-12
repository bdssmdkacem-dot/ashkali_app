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
  String? _droppedBinId; // brief visual feedback before advancing
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    final pool = List<String>.from(widget.shapeIds)..shuffle();
    _targetId = pool.first;
    final others = pool.skip(1).take(2).toList();
    _binIds = [_targetId, ...others]..shuffle();
  }

  Future<void> _onAccept(String binId) async {
    if (_droppedBinId != null) return; // already answered
    final passed = binId == _targetId;
    setState(() {
      _droppedBinId = binId;
      _isCorrect = passed;
    });
    if (passed) {
      await AudioService.instance.playSuccess();
    } else {
      await AudioService.instance.playError();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onResult(passed);
  }

  @override
  Widget build(BuildContext context) {
    final targetMeta = shapeById(_targetId);
    final targetColor = AppColors.shapeColors[targetMeta.id] ?? AppColors.teal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            const Text('اسحب الشكل إلى الصندوق الصحيح', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 20),
        Draggable<String>(
          data: _targetId,
          feedback: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 100, autoRotate: false),
          childWhenDragging: Opacity(
            opacity: 0.25,
            child: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 120),
          ),
          child: Shape3DWidget(type: targetMeta.renderType, color: targetColor, size: 120),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _binIds.map((binId) {
            final meta = shapeById(binId);
            return DragTarget<String>(
              onWillAcceptWithDetails: (_) => _droppedBinId == null,
              onAcceptWithDetails: (details) => _onAccept(binId),
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                final isAnswered = _droppedBinId == binId;
                Color bg = Colors.white;
                Color borderColor = Colors.grey.shade300;
                if (isAnswered) {
                  bg = _isCorrect ? AppColors.successBg : AppColors.errorBg;
                  borderColor = _isCorrect ? AppColors.success : AppColors.error;
                } else if (isHovering) {
                  bg = AppColors.gold.withOpacity(0.15);
                  borderColor = AppColors.gold;
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(color: borderColor, width: isHovering || isAnswered ? 3 : 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Center(child: Text(meta.nameArabic, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
