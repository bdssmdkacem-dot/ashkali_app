enum FormulaCalcType { perimeter, area }

/// Metadata for a perimeter/area "rule" - the Arabic formula text shown
/// at the start of the stage, a simplified explanation, the labels for
/// the dimensions the child will see values for, and how to compute the
/// correct answer from those dimension values.
class FormulaMeta {
  final String shapeId;
  final FormulaCalcType calcType;
  final String ruleArabic; // e.g. "محيط المربع = الضلع × 4"
  final String explanationArabic; // simplified, kid-friendly explanation
  final List<String> dimensionLabels; // e.g. ['طول الضلع'] or ['الطول', 'العرض']
  final num Function(List<int> dims) compute;
  final String unitSuffix; // 'سم' for perimeter, 'سم²' for area

  const FormulaMeta({
    required this.shapeId,
    required this.calcType,
    required this.ruleArabic,
    required this.explanationArabic,
    required this.dimensionLabels,
    required this.compute,
    required this.unitSuffix,
  });
}
