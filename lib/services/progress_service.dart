import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter_model.dart';
import '../data/chapters_data.dart';

/// Singleton progress service - Hive persistence, same pattern as the
/// rest of the series (وقتي / أرقامي / حروفي).
class ProgressService {
  ProgressService._internal();
  static final ProgressService instance = ProgressService._internal();

  static const _boxName = 'ashkali_progress';
  late Box<ChapterProgress> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(ChapterProgressAdapter());
    _box = await Hive.openBox<ChapterProgress>(_boxName);

    // Seed all 13 chapters on first run; chapter 1 starts unlocked.
    if (_box.isEmpty) {
      for (final def in kChapters) {
        await _box.put(
          def.number,
          ChapterProgress(
            chapterNumber: def.number,
            isUnlocked: def.number == 1,
          ),
        );
      }
    }
    _initialized = true;
  }

  ChapterProgress progressFor(int chapterNumber) => _box.get(chapterNumber)!;

  List<ChapterProgress> get allProgress =>
      kChapters.map((d) => progressFor(d.number)).toList();

  Future<void> completeChapter(int chapterNumber, {required int stars}) async {
    final p = progressFor(chapterNumber);
    p.isCompleted = true;
    p.starsEarned = stars > p.starsEarned ? stars : p.starsEarned;
    await p.save();

    // Unlock the next chapter.
    final nextNumber = chapterNumber + 1;
    if (nextNumber <= kChapters.length) {
      final next = progressFor(nextNumber);
      next.isUnlocked = true;
      await next.save();
    }
  }

  double get overallCompletionRatio {
    final completed = allProgress.where((p) => p.isCompleted).length;
    return completed / kChapters.length;
  }
}
