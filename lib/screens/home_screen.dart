import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/chapters_data.dart';
import '../data/shapes_data.dart';
import '../models/chapter_model.dart';
import '../services/progress_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import 'chapter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    // Single banner, home screen only - never inside an activity.
    _bannerAd = AdService.instance.createHomeBannerAd(onLoaded: () => setState(() {}));
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = ProgressService.instance.overallCompletionRatio;
    final completedCount = ProgressService.instance.allProgress.where((p) => p.isCompleted).length;

    // Group chapters into two sections for a clearer mental model: the
    // core shape curriculum (1-13) vs. the newer math chapters (14-15).
    final shapeChapters = kChapters.where((c) => c.type != ChapterType.formula).toList();
    final formulaChapters = kChapters.where((c) => c.type == ChapterType.formula).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('أشكالي')),
      body: Column(
        children: [
          _OverallProgressHeader(ratio: ratio, completedCount: completedCount, total: kChapters.length),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                const _SectionHeader(title: 'رحلة الأشكال', icon: Icons.category),
                const SizedBox(height: 8),
                ...shapeChapters.map((def) => _buildTile(context, def)),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'الرياضيات', icon: Icons.calculate),
                const SizedBox(height: 8),
                ...formulaChapters.map((def) => _buildTile(context, def)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, ChapterDef def) {
    final progress = ProgressService.instance.progressFor(def.number);
    return _ChapterTile(
      def: def,
      progress: progress,
      onTap: () async {
        if (!progress.isUnlocked) return;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChapterScreen(chapterDef: def)),
        );
        setState(() {}); // refresh unlock/star state on return
      },
    );
  }
}

/// Sticky-feeling header (not actually pinned, but sits above the list)
/// showing overall progress across all 15 chapters at a glance.
class _OverallProgressHeader extends StatelessWidget {
  final double ratio;
  final int completedCount;
  final int total;

  const _OverallProgressHeader({required this.ratio, required this.completedCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold, size: 22),
              const SizedBox(width: 8),
              Text(
                'تقدمك: $completedCount من $total',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.night.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.night.withOpacity(0.6), letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final ChapterDef def;
  final ChapterProgress progress;
  final VoidCallback onTap;

  const _ChapterTile({required this.def, required this.progress, required this.onTap});

  IconData get _typeIcon {
    switch (def.type) {
      case ChapterType.core:
        return Icons.school;
      case ChapterType.review:
        return Icons.refresh;
      case ChapterType.bonus:
        return Icons.favorite;
      case ChapterType.finalChallenge:
        return Icons.emoji_events;
      case ChapterType.formula:
        return Icons.calculate;
    }
  }

  /// The tile's accent color: the shape's own color for single-shape
  /// chapters, a neutral teal/gold for multi-shape ones.
  Color _accentColor() {
    final isSingleShapeChapter = def.type == ChapterType.core || def.type == ChapterType.bonus;
    if (isSingleShapeChapter) {
      return AppColors.shapeColors[def.shapeIds.first] ?? AppColors.teal;
    }
    if (def.type == ChapterType.finalChallenge) return AppColors.gold;
    if (def.type == ChapterType.formula) return AppColors.terracotta;
    return AppColors.teal; // review
  }

  @override
  Widget build(BuildContext context) {
    final locked = !progress.isUnlocked;
    final isSingleShapeChapter = def.type == ChapterType.core || def.type == ChapterType.bonus;
    final primaryShape = isSingleShapeChapter ? shapeById(def.shapeIds.first) : null;
    final accent = _accentColor();

    return AnimatedOpacity(
      opacity: locked ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Color accent strip - shape color, or the type accent for multi-shape chapters.
                  Container(width: 6, color: locked ? Colors.grey.shade400 : accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: locked ? Colors.grey.shade300 : accent.withOpacity(0.15),
                            child: locked
                                ? Icon(Icons.lock, color: Colors.grey.shade600)
                                : (primaryShape != null
                                    ? ClipOval(
                                        child: Image.asset(
                                          primaryShape.iconAsset,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Icon(_typeIcon, color: accent)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  def.titleArabic,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: locked ? Colors.grey.shade600 : AppColors.night,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(_typeIcon, size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(_typeLabel(def.type), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (progress.isCompleted)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                3,
                                (i) => Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: i < progress.starsEarned ? AppColors.gold : Colors.grey.shade300,
                                ),
                              ),
                            )
                          else if (!locked)
                            Icon(Icons.chevron_left, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(ChapterType type) {
    switch (type) {
      case ChapterType.core:
        return 'درس';
      case ChapterType.review:
        return 'مراجعة';
      case ChapterType.bonus:
        return 'إضافي';
      case ChapterType.finalChallenge:
        return 'تحدي نهائي';
      case ChapterType.formula:
        return 'قاعدة رياضية';
    }
  }
}
