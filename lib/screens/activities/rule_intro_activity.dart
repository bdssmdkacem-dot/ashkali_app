import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../data/formulas_data.dart';
import '../../models/formula_model.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shape_3d_widget.dart';

/// Shown at the start of a formula stage (chapters 14/15): the shape,
/// the formula itself, and a simplified Arabic explanation - read aloud
/// via TTS - before the child attempts the calculation quiz.
class RuleIntroActivity extends StatefulWidget {
  final String shapeId;
  final FormulaCalcType calcType;
  final VoidCallback onDone;

  const RuleIntroActivity({
    super.key,
    required this.shapeId,
    required this.calcType,
    required this.onDone,
  });

  @override
  State<RuleIntroActivity> createState() => _RuleIntroActivityState();
}

class _RuleIntroActivityState extends State<RuleIntroActivity> {
  @override
  void initState() {
    super.initState();
    final formula = formulaFor(widget.shapeId, widget.calcType);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speak('${formula.ruleArabic}. ${formula.explanationArabic}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final shapeMeta = shapeById(widget.shapeId);
    final formula = formulaFor(widget.shapeId, widget.calcType);
    final color = AppColors.shapeColors[shapeMeta.id] ?? AppColors.teal;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Shape3DWidget(type: shapeMeta.renderType, color: color, size: 140),
          const SizedBox(height: 16),
          Text(shapeMeta.nameArabic, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Text(
              formula.ruleArabic,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              formula.explanationArabic,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: IconButton(
              icon: Icon(Icons.volume_up, size: 26, color: color),
              onPressed: () => AudioService.instance
                  .speak('${formula.ruleArabic}. ${formula.explanationArabic}'),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              AudioService.instance.playTap();
              widget.onDone();
            },
            child: const Text('فهمت، هيا نجرب'),
          ),
        ],
      ),
    );
  }
}
