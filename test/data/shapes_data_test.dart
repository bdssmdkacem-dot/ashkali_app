import 'package:flutter_test/flutter_test.dart';
import 'package:ashkali/data/shapes_data.dart';

void main() {
  group('kShapes data integrity', () {
    test('has exactly 10 shapes with unique ids', () {
      expect(kShapes.length, 10);
      final ids = kShapes.map((s) => s.id).toSet();
      expect(ids.length, 10, reason: 'shape ids must be unique');
    });

    test('every shape has non-empty real-world and distractor images', () {
      for (final shape in kShapes) {
        expect(shape.realWorldImages, isNotEmpty, reason: '${shape.id} has no real-world images');
        expect(shape.distractorImages, isNotEmpty, reason: '${shape.id} has no distractor images');
        for (final path in [...shape.realWorldImages, ...shape.distractorImages]) {
          expect(path.endsWith('.png'), isTrue, reason: '$path should be a .png asset');
        }
      }
    });

    test('every shape has a non-empty icon asset path', () {
      for (final shape in kShapes) {
        expect(shape.iconAsset, isNotEmpty);
        expect(shape.iconAsset.endsWith('.png'), isTrue);
      }
    });

    test('sides values match known geometry', () {
      const noSides = {'circle', 'oval', 'heart'};
      const fourSides = {'square', 'rectangle', 'rhombus'};
      for (final shape in kShapes) {
        if (noSides.contains(shape.id)) {
          expect(shape.sides, -1, reason: '${shape.id} should have no side count');
        } else if (fourSides.contains(shape.id)) {
          expect(shape.sides, 4, reason: '${shape.id} should have 4 sides');
        } else if (shape.id == 'triangle') {
          expect(shape.sides, 3);
        } else if (shape.id == 'star' || shape.id == 'pentagon') {
          expect(shape.sides, 5);
        } else if (shape.id == 'hexagon') {
          expect(shape.sides, 6);
        }
      }
    });

    test('shapeById finds every shape and throws for an unknown id', () {
      for (final shape in kShapes) {
        expect(shapeById(shape.id).id, shape.id);
      }
      expect(() => shapeById('not_a_real_shape'), throwsStateError);
    });
  });
}
