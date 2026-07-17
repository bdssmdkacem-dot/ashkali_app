import '../models/chapter_model.dart';

const _coreActivities = [
  ActivityType.intro,
  ActivityType.trace,
  ActivityType.findRealLife,
  ActivityType.sort,
  ActivityType.sidesQuiz,
];

const _reviewActivities = [
  ActivityType.sort,
  ActivityType.findRealLife,
  ActivityType.sidesQuiz,
];

/// The locked 13-chapter structure for أشكالي, mirroring وقتي's
/// teach -> teach -> teach -> review rhythm.
final List<ChapterDef> kChapters = [
  const ChapterDef(
    number: 1,
    titleArabic: 'دائرة',
    type: ChapterType.core,
    shapeIds: ['circle'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 2,
    titleArabic: 'مربع',
    type: ChapterType.core,
    shapeIds: ['square'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 3,
    titleArabic: 'مثلث',
    type: ChapterType.core,
    shapeIds: ['triangle'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 4,
    titleArabic: 'مراجعة ١',
    type: ChapterType.review,
    shapeIds: ['circle', 'square', 'triangle'],
    activities: _reviewActivities,
  ),
  const ChapterDef(
    number: 5,
    titleArabic: 'مستطيل',
    type: ChapterType.core,
    shapeIds: ['rectangle'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 6,
    titleArabic: 'بيضاوي',
    type: ChapterType.core,
    shapeIds: ['oval'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 7,
    titleArabic: 'نجمة',
    type: ChapterType.core,
    shapeIds: ['star'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 8,
    titleArabic: 'مراجعة ٢',
    // spaced repetition: mixes new (5-7) with old (1-3)
    type: ChapterType.review,
    shapeIds: ['rectangle', 'oval', 'star', 'circle', 'square', 'triangle'],
    activities: _reviewActivities,
  ),
  const ChapterDef(
    number: 9,
    titleArabic: 'قلب',
    type: ChapterType.bonus,
    shapeIds: ['heart'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 10,
    titleArabic: 'معين',
    type: ChapterType.core,
    shapeIds: ['rhombus'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 11,
    titleArabic: 'خماسي',
    type: ChapterType.core,
    shapeIds: ['pentagon'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 12,
    titleArabic: 'سداسي',
    type: ChapterType.core,
    shapeIds: ['hexagon'],
    activities: _coreActivities,
  ),
  const ChapterDef(
    number: 13,
    titleArabic: 'التحدي النهائي',
    type: ChapterType.finalChallenge,
    shapeIds: [
      'circle', 'square', 'triangle', 'rectangle', 'oval',
      'star', 'heart', 'rhombus', 'pentagon', 'hexagon',
    ],
    activities: [ActivityType.finalGauntlet],
  ),
];

ChapterDef chapterByNumber(int n) => kChapters.firstWhere((c) => c.number == n);
