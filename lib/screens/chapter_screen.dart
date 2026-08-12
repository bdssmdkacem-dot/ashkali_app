import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../data/chapters_data.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import 'activities/intro_activity.dart';
import 'activities/trace_activity.dart';
import 'activities/find_real_life_activity.dart';
import 'activities/sort_activity.dart';
import 'activities/sides_quiz_activity.dart';
import 'activities/rule_intro_activity.dart';
import 'activities/calc_activity.dart';

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
    final hasNextChapter = widget.chapterDef.number < kChapters.length;
    await ProgressService.instance.completeChapter(widget.chapterDef.number, stars: stars);
    _playCompletionSfxSequence(hasNextChapter: hasNextChapter);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(stars: stars, onContinue: () async {
        Navigator.of(context).pop(); // dialog
        Navigator.of(context).pop(); // chapter screen -> home
        // Interstitial only at review/final/formula breakpoints (4, 8, 13, 15) -
        // never after a core teaching chapter. Shown after navigation
        // so it never interrupts mid-activity.
        await AdService.instance.maybeShowInterstitial(widget.chapterDef.number);
      }),
    );
  }

  /// Fire-and-forget celebratory sequence: completion chime, then a star
  /// twinkle, then (if a new chapter was just unlocked) the unlock chime.
  /// Not awaited before showing the star dialog, so it plays in the
  /// background while the dialog is already visible.
  Future<void> _playCompletionSfxSequence({required bool hasNextChapter}) async {
    await AudioService.instance.playComplete();
    await Future.delayed(const Duration(milliseconds: 450));
    await AudioService.instance.playStar();
    if (hasNextChapter) {
      await Future.delayed(const Duration(milliseconds: 350));
      await AudioService.instance.playUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final progressValue = _stepIndex / _steps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterDef.titleArabic),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progressValue),
                duration: const Duration(milliseconds: 350),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'الخطوة ${_stepIndex + 1} من ${_steps.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_stepIndex),
                  child: _buildActivity(step),
                ),
              ),
            ),
          ),
        ),
      ),
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
      case ActivityType.ruleIntro:
        return RuleIntroActivity(
          shapeId: step.shapeId,
          calcType: widget.chapterDef.formulaType!,
          onDone: () => _onStepResult(true),
        );
      case ActivityType.calc:
        return CalcActivity(
          shapeId: step.shapeId,
          calcType: widget.chapterDef.formulaType!,
          onResult: _onStepResult,
        );
    }
  }
}

class _Step {
  final String shapeId;
  final ActivityType activity;
  _Step({required this.shapeId, required this.activity});
}

/// Celebration dialog shown at chapter completion - stars pop in one at a
/// time with a bounce, instead of appearing all at once.
class _CompletionDialog extends StatefulWidget {
  final int stars;
  final VoidCallback onContinue;
  const _CompletionDialog({required this.stars, required this.onContinue});

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أحسنت! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final filled = i < widget.stars;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + i * 180),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Icon(
                    Icons.star_rounded,
                    color: filled ? AppColors.gold : Colors.grey.shade300,
                    size: 44,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                child: const Text('متابعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
