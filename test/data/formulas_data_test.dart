import 'package:flutter_test/flutter_test.dart';
import 'package:ashkali/data/formulas_data.dart';
import 'package:ashkali/models/formula_model.dart';

void main() {
  group('perimeter formulas (chapter 14)', () {
    test('circle: diameter x 3', () {
      expect(formulaFor('circle', FormulaCalcType.perimeter).compute([10]), 30);
    });
    test('square: side x 4', () {
      expect(formulaFor('square', FormulaCalcType.perimeter).compute([4]), 16);
    });
    test('triangle (equilateral): side x 3', () {
      expect(formulaFor('triangle', FormulaCalcType.perimeter).compute([6]), 18);
    });
    test('rectangle: (length + width) x 2', () {
      expect(formulaFor('rectangle', FormulaCalcType.perimeter).compute([3, 5]), 16);
    });
    test('rhombus: side x 4', () {
      expect(formulaFor('rhombus', FormulaCalcType.perimeter).compute([5]), 20);
    });
    test('pentagon: side x 5', () {
      expect(formulaFor('pentagon', FormulaCalcType.perimeter).compute([3]), 15);
    });
    test('hexagon: side x 6', () {
      expect(formulaFor('hexagon', FormulaCalcType.perimeter).compute([2]), 12);
    });
  });

  group('area formulas (chapter 15)', () {
    test('square: side x side', () {
      expect(formulaFor('square', FormulaCalcType.area).compute([4]), 16);
    });
    test('rectangle: length x width', () {
      expect(formulaFor('rectangle', FormulaCalcType.area).compute([3, 5]), 15);
    });
    test('triangle: (base x height) / 2', () {
      expect(formulaFor('triangle', FormulaCalcType.area).compute([6, 4]), 12);
    });
  });

  group('formula metadata sanity', () {
    test('every perimeter formula dimension count matches its compute() usage', () {
      for (final f in kPerimeterFormulas) {
        // Feeding exactly dimensionLabels.length values should never throw
        // a range error inside compute().
        final dims = List.generate(f.dimensionLabels.length, (i) => i + 2);
        expect(() => f.compute(dims), returnsNormally, reason: '${f.shapeId} perimeter compute() failed');
      }
    });

    test('every area formula dimension count matches its compute() usage', () {
      for (final f in kAreaFormulas) {
        final dims = List.generate(f.dimensionLabels.length, (i) => i + 2);
        expect(() => f.compute(dims), returnsNormally, reason: '${f.shapeId} area compute() failed');
      }
    });

    test('all formula results are positive for positive dimensions', () {
      for (final f in [...kPerimeterFormulas, ...kAreaFormulas]) {
        final dims = List.generate(f.dimensionLabels.length, (i) => i + 2);
        expect(f.compute(dims) > 0, isTrue, reason: '${f.shapeId} produced a non-positive result');
      }
    });

    test('unit suffix is سم for perimeter and سم² for area', () {
      for (final f in kPerimeterFormulas) {
        expect(f.unitSuffix, 'سم');
      }
      for (final f in kAreaFormulas) {
        expect(f.unitSuffix, 'سم²');
      }
    });
  });
}
