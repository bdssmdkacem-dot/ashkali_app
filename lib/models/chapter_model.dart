import 'package:hive/hive.dart';
import 'formula_model.dart';

part 'chapter_model.g.dart';

enum ChapterType { core, review, bonus, finalChallenge, formula }

enum ActivityType {
  intro,        // TTS + 3D shape presentation
  trace,        // pixel-comparison outline tracing
  findRealLife, // match shape to real-world emoji object
  sort,         // drag-and-drop sorting bins
  sidesQuiz,    // "how many sides?" (skipped for 0-side shapes)
  ruleIntro,    // shows the formula + a simplified explanation before calc
  calc,         // perimeter/area calculation quiz (see ChapterDef.formulaType)
}

@HiveType(typeId: 2)
class ChapterProgress extends HiveObject {
  @HiveField(0)
  final int chapterNumber; // 1-15

  @HiveField(1)
  int starsEarned; // 0-3

  @HiveField(2)
  bool isUnlocked;

  @HiveField(3)
  bool isCompleted;

  ChapterProgress({
    required this.chapterNumber,
    this.starsEarned = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
  });
}

/// Static chapter definition (not stored in Hive - only progress is).
class ChapterDef {
  final int number; // 1-15
  final String titleArabic;
  final ChapterType type;
  final List<String> shapeIds; // which shapes this chapter covers/reviews
  final List<ActivityType> activities;
  final FormulaCalcType? formulaType; // set only for ChapterType.formula chapters

  const ChapterDef({
    required this.number,
    required this.titleArabic,
    required this.type,
    required this.shapeIds,
    required this.activities,
    this.formulaType,
  });
}
