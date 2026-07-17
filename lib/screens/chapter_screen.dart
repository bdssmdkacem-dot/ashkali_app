import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import 'activities/intro_activity.dart';
import 'activities/trace_activity.dart';
import 'activities/find_real_life_activity.dart';
import 'activities/sort_activity.dart';
import 'activities/sides_quiz_activity.dart';

/// Walks the child through def.activities in order, one per shape in
/// def.shapeIds, tracking correctness to compute a 1-3 star rating,
/// same flow as وقتي / أرقامي / حروفي chapters.
class ChapterScreen extends StatefulWidget {
  final ChapterDef chapterDef;
  const ChapterScreen({super.key, required this.chapterDef});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late final List<_Step> _steps;
  int _stepIndex = 0;
  int _correctCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
  }

  List<_Step> _buildSteps() {
    final steps = <_Step>[];
    for (final shapeId in widget.chapterDef.shapeIds) {
      for (final activity in widget.chapterDef.activities) {
        steps.add(_Step(shapeId: shapeId, activity: activity));
      }
    }
    return steps;
  }

  void _onStepResult(bool passed) {
    _totalCount++;
    if (passed) _correctCount++;
    if (_stepIndex + 1 >= _steps.length) {
      _finishChapter();
    } else {
      setState(() => _stepIndex++);
    }
  }

  Future<void> _finishChapter() async {
    final ratio = _totalCount == 0 ? 1.0 : _correctCount / _totalCount;
    final stars = ratio >= 0.9 ? 3 : (ratio >= 0.6 ? 2 : 1);
    await ProgressService.instance.completeChapter(widget.chapterDef.number, stars: stars);
    await AudioService.instance.playComplete();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('أحسنت! 🎉'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Icon(Icons.star, color: i < stars ? Colors.amber : Colors.grey.shade300, size: 32),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // chapter screen -> home
              // Interstitial only at review/final breakpoints (4, 8, 13) -
              // never after a core teaching chapter. Shown after navigation
              // so it never interrupts mid-activity.
              await AdService.instance.maybeShowInterstitial(widget.chapterDef.number);
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterDef.titleArabic),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: (_stepIndex) / _steps.length),
        ),
      ),
      body: Center(child: _buildActivity(step)),
    );
  }

  Widget _buildActivity(_Step step) {
    switch (step.activity) {
      case ActivityType.intro:
        return IntroActivity(shapeId: step.shapeId, onDone: () => _onStepResult(true));
      case ActivityType.trace:
        return TraceActivity(shapeId: step.shapeId, onResult: _onStepResult);
      case ActivityType.findRealLife:
        return FindRealLifeActivity(shapeId: step.shapeId, onResult: _onStepResult);
      case ActivityType.sort:
        return SortActivity(shapeIds: widget.chapterDef.shapeIds, onResult: _onStepResult);
      case ActivityType.sidesQuiz:
        return SidesQuizActivity(shapeId: step.shapeId, onResult: _onStepResult);
      case ActivityType.finalGauntlet:
        // Ch.13 boss level - cycles all activity types across all shapes.
        return FindRealLifeActivity(shapeId: step.shapeId, onResult: _onStepResult);
    }
  }
}

class _Step {
  final String shapeId;
  final ActivityType activity;
  _Step({required this.shapeId, required this.activity});
}
