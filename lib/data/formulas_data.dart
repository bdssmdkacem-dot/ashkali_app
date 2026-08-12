import '../models/formula_model.dart';

/// Chapter 14 (المحيط) - shapes with a clean, kid-level perimeter formula.
/// Oval/star/heart are skipped - they don't have a simple straight-side
/// formula appropriate for this age group.
final List<FormulaMeta> kPerimeterFormulas = [
  FormulaMeta(
    shapeId: 'circle',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط الدائرة ≈ القطر × 3',
    explanationArabic:
        'المحيط هو طول الخط المحيط بالشكل بالكامل. في الدائرة، نضرب طول القطر '
        '(الخط الذي يمر من طرف إلى آخر عبر المركز) في العدد 3 تقريباً.',
    dimensionLabels: ['القطر'],
    compute: (dims) => dims[0] * 3,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'square',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط المربع = الضلع × 4',
    explanationArabic:
        'للمربع 4 أضلاع متساوية الطول، لذلك نضرب طول أي ضلع منها في 4 '
        'لنحصل على طول الخط المحيط بالشكل كله.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * 4,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'triangle',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط المثلث المتساوي الأضلاع = الضلع × 3',
    explanationArabic:
        'عندما تكون أضلاع المثلث الثلاثة متساوية الطول، نضرب طول أحد '
        'الأضلاع في 3 فقط.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * 3,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'rectangle',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط المستطيل = (الطول + العرض) × 2',
    explanationArabic:
        'نجمع الطول مع العرض أولاً، ثم نضرب الناتج في 2، لأن كل بعد '
        '(الطول والعرض) يتكرر مرتين في المستطيل.',
    dimensionLabels: ['الطول', 'العرض'],
    compute: (dims) => (dims[0] + dims[1]) * 2,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'rhombus',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط المعين = الضلع × 4',
    explanationArabic:
        'المعين له 4 أضلاع متساوية الطول تماماً مثل المربع، لذلك نضرب '
        'طول أي ضلع في 4.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * 4,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'pentagon',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط الخماسي = الضلع × 5',
    explanationArabic: 'الشكل الخماسي له 5 أضلاع متساوية، فنضرب طول ضلع واحد في 5.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * 5,
    unitSuffix: 'سم',
  ),
  FormulaMeta(
    shapeId: 'hexagon',
    calcType: FormulaCalcType.perimeter,
    ruleArabic: 'محيط السداسي = الضلع × 6',
    explanationArabic: 'الشكل السداسي له 6 أضلاع متساوية، فنضرب طول ضلع واحد في 6.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * 6,
    unitSuffix: 'سم',
  ),
];

/// Chapter 15 (المساحة) - only the 3 shapes with an area formula that's
/// reasonable to teach at this level.
final List<FormulaMeta> kAreaFormulas = [
  FormulaMeta(
    shapeId: 'square',
    calcType: FormulaCalcType.area,
    ruleArabic: 'مساحة المربع = الضلع × الضلع',
    explanationArabic:
        'نضرب طول الضلع في نفسه، لأن طول وعرض المربع متساويان دائماً.',
    dimensionLabels: ['طول الضلع'],
    compute: (dims) => dims[0] * dims[0],
    unitSuffix: 'سم²',
  ),
  FormulaMeta(
    shapeId: 'rectangle',
    calcType: FormulaCalcType.area,
    ruleArabic: 'مساحة المستطيل = الطول × العرض',
    explanationArabic: 'نضرب طول المستطيل في عرضه لنحصل على مساحته الكاملة.',
    dimensionLabels: ['الطول', 'العرض'],
    compute: (dims) => dims[0] * dims[1],
    unitSuffix: 'سم²',
  ),
  FormulaMeta(
    shapeId: 'triangle',
    calcType: FormulaCalcType.area,
    ruleArabic: 'مساحة المثلث = (القاعدة × الارتفاع) ÷ 2',
    explanationArabic:
        'نضرب طول القاعدة في الارتفاع، ثم نقسم الناتج على 2 - '
        'لأن المثلث هو نصف المستطيل الذي يحيط به.',
    dimensionLabels: ['القاعدة', 'الارتفاع'],
    compute: (dims) => (dims[0] * dims[1]) ~/ 2,
    unitSuffix: 'سم²',
  ),
];

FormulaMeta formulaFor(String shapeId, FormulaCalcType type) {
  final list = type == FormulaCalcType.perimeter ? kPerimeterFormulas : kAreaFormulas;
  return list.firstWhere((f) => f.shapeId == shapeId);
}
