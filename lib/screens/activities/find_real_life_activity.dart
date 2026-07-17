import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../services/audio_service.dart';

/// "Find it in real life" - pick the emoji object that matches the shape
/// from a mix of correct + distractor options.
class FindRealLifeActivity extends StatefulWidget {
  final String shapeId;
  final void Function(bool passed) onResult;
  const FindRealLifeActivity({super.key, required this.shapeId, required this.onResult});

  @override
  State<FindRealLifeActivity> createState() => _FindRealLifeActivityState();
}

class _FindRealLifeActivityState extends State<FindRealLifeActivity> {
  late final List<String> _options;
  late final String _correctEmoji;
  String? _selected;

  @override
  void initState() {
    super.initState();
    final meta = shapeById(widget.shapeId);
    final rnd = Random();
    _correctEmoji = meta.realWorldEmojis[rnd.nextInt(meta.realWorldEmojis.length)];
    final distractors = List<String>.from(meta.distractorEmojis)..shuffle();
    _options = [_correctEmoji, ...distractors.take(2)]..shuffle();
  }

  Future<void> _select(String emoji) async {
    if (_selected != null) return;
    setState(() => _selected = emoji);
    final passed = emoji == _correctEmoji;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('أين شكل ${meta.nameArabic} في الحياة؟',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          children: _options.map((emoji) {
            final isSelected = _selected == emoji;
            final isCorrect = emoji == _correctEmoji;
            Color? bg;
            if (_selected != null && isSelected) {
              bg = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
            }
            return GestureDetector(
              onTap: () => _select(emoji),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                child: Text(emoji, style: const TextStyle(fontSize: 48)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
