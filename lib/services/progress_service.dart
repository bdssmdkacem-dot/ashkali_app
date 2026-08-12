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

    // Seed any chapter missing from the box - covers both a fresh install
    // and an app update that added new chapters (14/15) to an existing
    // install. Seeding only `if (_box.isEmpty)` would leave those keys
    // permanently missing for upgrading users, and progressFor() would
    // crash the first time their code reached chapter 14.
    for (final def in kChapters) {
      if (!_box.containsKey(def.number)) {
        await _box.put(
          def.number,
          ChapterProgress(chapterNumber: def.number, isUnlocked: def.number == 1),
        );
      }
    }

    // Migration: if a newly-added chapter's predecessor was already
    // completed before that chapter existed (e.g. chapter 13 finished
    // back when it was the last one), unlock it now instead of leaving
    // it stuck locked with no way to reach it.
    for (final def in kChapters) {
      if (def.number == 1) continue;
      final progress = progressFor(def.number);
      final previous = progressFor(def.number - 1);
      if (!progress.isUnlocked && previous.isCompleted) {
        progress.isUnlocked = true;
        await progress.save();
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
