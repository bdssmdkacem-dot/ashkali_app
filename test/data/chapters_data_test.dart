import 'package:flutter_test/flutter_test.dart';
import 'package:ashkali/data/chapters_data.dart';
import 'package:ashkali/data/shapes_data.dart';
import 'package:ashkali/data/formulas_data.dart';
import 'package:ashkali/models/chapter_model.dart';

void main() {
  group('kChapters structural integrity', () {
    test('has exactly 15 chapters numbered 1..15 in order', () {
      expect(kChapters.length, 15);
      for (var i = 0; i < kChapters.length; i++) {
        expect(kChapters[i].number, i + 1);
      }
    });

    test('every shapeId referenced actually exists in kShapes', () {
      final validIds = kShapes.map((s) => s.id).toSet();
      for (final chapter in kChapters) {
        for (final shapeId in chapter.shapeIds) {
          expect(validIds.contains(shapeId), isTrue,
              reason: 'chapter ${chapter.number} references unknown shape "$shapeId"');
        }
      }
    });

    test('formula chapters have formulaType set, all others do not', () {
      for (final chapter in kChapters) {
        if (chapter.type == ChapterType.formula) {
          expect(chapter.formulaType, isNotNull,
              reason: 'formula chapter ${chapter.number} must set formulaType');
        } else {
          expect(chapter.formulaType, isNull,
              reason: 'non-formula chapter ${chapter.number} should not set formulaType');
        }
      }
    });

    test('every shape in a formula chapter actually has a matching formula', () {
      for (final chapter in kChapters.where((c) => c.type == ChapterType.formula)) {
        for (final shapeId in chapter.shapeIds) {
          // Throws (via firstWhere) if no FormulaMeta exists for this pairing.
          expect(() => formulaFor(shapeId, chapter.formulaType!), returnsNormally,
              reason: 'no formula for $shapeId / ${chapter.formulaType}');
        }
      }
    });

    test('chapter 13 (final challenge) covers all 10 shapes', () {
      final ch13 = kChapters.firstWhere((c) => c.number == 13);
      expect(ch13.shapeIds.toSet().length, 10);
      expect(ch13.type, ChapterType.finalChallenge);
    });

    test('chapter 1 has no shapeIds overlap issues and every chapter has at least one activity', () {
      for (final chapter in kChapters) {
        expect(chapter.shapeIds, isNotEmpty);
        expect(chapter.activities, isNotEmpty);
      }
    });

    test('chapterByNumber matches kChapters and throws for an invalid number', () {
      for (final chapter in kChapters) {
        expect(chapterByNumber(chapter.number).number, chapter.number);
      }
      expect(() => chapterByNumber(999), throwsStateError);
    });
  });
}
