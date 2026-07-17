import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/chapters_data.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('أشكالي')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kChapters.length,
              itemBuilder: (context, index) {
                final def = kChapters[index];
                final progress = ProgressService.instance.progressFor(def.number);
                return _ChapterTile(def: def, progress: progress, onTap: () async {
                  if (!progress.isUnlocked) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChapterScreen(chapterDef: def)),
                  );
                  setState(() {}); // refresh unlock/star state on return
                });
              },
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !progress.isUnlocked;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: locked ? Colors.grey.shade300 : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: locked ? Colors.grey : AppColors.teal,
          child: locked
              ? const Icon(Icons.lock, color: Colors.white)
              : Text('${def.number}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(def.titleArabic, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(_typeIcon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(_typeLabel(def.type)),
          ],
        ),
        trailing: progress.isCompleted
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star,
                    size: 18,
                    color: i < progress.starsEarned ? AppColors.gold : Colors.grey.shade300,
                  ),
                ),
              )
            : null,
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
    }
  }
}
