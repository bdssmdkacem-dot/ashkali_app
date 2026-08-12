import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../data/formulas_data.dart';
import '../../models/formula_model.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shape_3d_widget.dart';

/// Generic perimeter/area calculation quiz. Randomly generates small
/// integer dimension values, shows them next to the shape, and asks the
/// child to pick the correct result from 3 multiple-choice options.
class CalcActivity extends StatefulWidget {
  final String shapeId;
  final FormulaCalcType calcType;
  final void Function(bool passed) onResult;

  const CalcActivity({
    super.key,
    required this.shapeId,
    required this.calcType,
    required this.onResult,
  });

  @override
  State<CalcActivity> createState() => _CalcActivityState();
}

class _CalcActivityState extends State<CalcActivity> {
  late final FormulaMeta _formula;
  late final List<int> _dims;
  late final num _correctAnswer;
  late final List<num> _options;
  num? _selected;

  @override
  void initState() {
    super.initState();
    _formula = formulaFor(widget.shapeId, widget.calcType);
    final rnd = Random();
    _dims = List.generate(_formula.dimensionLabels.length, (_) => rnd.nextInt(8) + 2); // 2..9
    _correctAnswer = _formula.compute(_dims);

    final distractors = <num>{};
    while (distractors.length < 2) {
      final offset = rnd.nextInt(5) + 2; // 2..6
      final candidate = rnd.nextBool() ? _correctAnswer + offset : _correctAnswer - offset;
      if (candidate > 0 && candidate != _correctAnswer) distractors.add(candidate);
    }
    _options = [_correctAnswer, ...distractors]..shuffle();
  }

  Future<void> _select(num value) async {
    if (_selected != null) return;
    setState(() => _selected = value);
    final passed = value == _correctAnswer;
    if (passed) {
      await AudioService.instance.playSuccess();
    } else {
      await AudioService.instance.playError();
    }
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onResult(passed);
  }

  @override
  Widget build(BuildContext context) {
    final shapeMeta = shapeById(widget.shapeId);
    final color = AppColors.shapeColors[shapeMeta.id] ?? AppColors.teal;
    final questionLabel =
        widget.calcType == FormulaCalcType.perimeter ? 'محيط' : 'مساحة';

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Shape3DWidget(type: shapeMeta.renderType, color: color, size: 120, autoRotate: false),
          const SizedBox(height: 8),
          // Show the given dimension values, e.g. "الطول = 5 سم".
          Wrap(
            spacing: 16,
            children: List.generate(_formula.dimensionLabels.length, (i) {
              return Chip(
                label: Text('${_formula.dimensionLabels[i]} = ${_dims[i]} سم'),
                backgroundColor: AppColors.sand,
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('كم يساوي $questionLabel ${shapeMeta.nameArabic}؟',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _options.map((value) {
              final isSelected = _selected == value;
              final isCorrect = value == _correctAnswer;
              final bool? state = isSelected ? isCorrect : null;
              return GestureDetector(
                onTap: () => _select(value),
                child: AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Container(
                    width: 104,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: answerTileDecoration(isSelectedAndCorrect: state),
                    child: Text('$value ${_formula.unitSuffix}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
