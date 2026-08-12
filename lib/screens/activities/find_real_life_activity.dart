import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';

/// "Find it in real life" - pick the illustrated real-world object that
/// matches the shape from a mix of correct + distractor options.
class FindRealLifeActivity extends StatefulWidget {
  final String shapeId;
  final void Function(bool passed) onResult;
  const FindRealLifeActivity({super.key, required this.shapeId, required this.onResult});

  @override
  State<FindRealLifeActivity> createState() => _FindRealLifeActivityState();
}

class _FindRealLifeActivityState extends State<FindRealLifeActivity> {
  late final List<String> _options;
  late final String _correctImage;
  String? _selected;

  @override
  void initState() {
    super.initState();
    final meta = shapeById(widget.shapeId);
    final rnd = Random();
    _correctImage = meta.realWorldImages[rnd.nextInt(meta.realWorldImages.length)];
    final distractors = List<String>.from(meta.distractorImages)..shuffle();
    _options = [_correctImage, ...distractors.take(2)]..shuffle();
  }

  Future<void> _select(String imagePath) async {
    if (_selected != null) return;
    setState(() => _selected = imagePath);
    final passed = imagePath == _correctImage;
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
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: _options.map((imagePath) {
            final isSelected = _selected == imagePath;
            final isCorrect = imagePath == _correctImage;
            final bool? state = isSelected ? isCorrect : null;
            return GestureDetector(
              onTap: () => _select(imagePath),
              child: AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(10),
                      decoration: answerTileDecoration(isSelectedAndCorrect: state),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                    if (state != null)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: state ? AppColors.success : AppColors.error,
                          child: Icon(state ? Icons.check : Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
