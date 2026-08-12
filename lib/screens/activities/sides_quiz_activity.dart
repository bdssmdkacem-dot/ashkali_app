import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';

/// "How many sides?" quiz. Automatically passes through for 0-side shapes
/// (circle, oval, heart) since they have no side count to quiz.
class SidesQuizActivity extends StatefulWidget {
  final String shapeId;
  final void Function(bool passed) onResult;
  const SidesQuizActivity({super.key, required this.shapeId, required this.onResult});

  @override
  State<SidesQuizActivity> createState() => _SidesQuizActivityState();
}

class _SidesQuizActivityState extends State<SidesQuizActivity> {
  late final List<int> _options;
  int? _selected;

  @override
  void initState() {
    super.initState();
    final meta = shapeById(widget.shapeId);
    if (meta.sides == -1) {
      // No sides to quiz - auto-pass immediately after first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onResult(true));
      _options = const [];
      return;
    }
    final rnd = Random();
    final wrongs = <int>{};
    while (wrongs.length < 2) {
      final candidate = meta.sides + (rnd.nextBool() ? 1 : -1) * (rnd.nextInt(2) + 1);
      if (candidate > 0 && candidate != meta.sides) wrongs.add(candidate);
    }
    _options = [meta.sides, ...wrongs]..shuffle();
  }

  Future<void> _select(int value) async {
    if (_selected != null) return;
    final meta = shapeById(widget.shapeId);
    setState(() => _selected = value);
    final passed = value == meta.sides;
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
    final meta = shapeById(widget.shapeId);
    if (meta.sides == -1) {
      return const SizedBox.shrink(); // auto-passes via initState callback
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('كم عدد أضلاع شكل ${meta.nameArabic}؟',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _options.map((value) {
            final isSelected = _selected == value;
            final isCorrect = value == meta.sides;
            final bool? state = isSelected ? isCorrect : null;
            return GestureDetector(
              onTap: () => _select(value),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: answerTileDecoration(isSelectedAndCorrect: state),
                  child: Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
