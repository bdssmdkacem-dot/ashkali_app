import '../models/shape_model.dart';

/// The 10 shapes of أشكالي, ordered easiest (0 sides) -> most complex.
/// This order drives chapters 1-3, 5-7, 9-12 (see chapters_data.dart).
const List<ShapeMeta> kShapes = [
  ShapeMeta(
    id: 'circle',
    nameArabic: 'دائرة',
    sides: -1,
    renderType: Shape3DType.sphere,
    realWorldEmojis: ['⚽', '🍪', '🌕', '🎡'],
    distractorEmojis: ['📐', '🧊', '🍕'],
  ),
  ShapeMeta(
    id: 'square',
    nameArabic: 'مربع',
    sides: 4,
    renderType: Shape3DType.cube,
    realWorldEmojis: ['🧊', '🎲', '🪟', '♟️'],
    distractorEmojis: ['⚽', '🍕', '⭐'],
  ),
  ShapeMeta(
    id: 'triangle',
    nameArabic: 'مثلث',
    sides: 3,
    renderType: Shape3DType.pyramid,
    realWorldEmojis: ['🍕', '⛰️', '🚩', '🔺'],
    distractorEmojis: ['🧊', '⚽', '🍩'],
  ),
  ShapeMeta(
    id: 'rectangle',
    nameArabic: 'مستطيل',
    sides: 4,
    renderType: Shape3DType.cuboid,
    realWorldEmojis: ['📱', '🚪', '📕', '🧱'],
    distractorEmojis: ['⚽', '🔺', '⭐'],
  ),
  ShapeMeta(
    id: 'oval',
    nameArabic: 'بيضاوي',
    sides: -1,
    renderType: Shape3DType.ellipsoid,
    realWorldEmojis: ['🥚', '🍈', '🏉', '🐟'],
    distractorEmojis: ['🧊', '🔺', '📕'],
  ),
  ShapeMeta(
    id: 'star',
    nameArabic: 'نجمة',
    sides: 5,
    renderType: Shape3DType.star3d,
    realWorldEmojis: ['⭐', '🌟', '✨', '🕋'],
    distractorEmojis: ['⚽', '🧊', '🥚'],
  ),
  ShapeMeta(
    id: 'heart',
    nameArabic: 'قلب',
    sides: -1,
    renderType: Shape3DType.heart3d,
    realWorldEmojis: ['❤️', '💝', '💌'],
    distractorEmojis: ['⭐', '🧊', '🥚'],
  ),
  ShapeMeta(
    id: 'rhombus',
    nameArabic: 'معين',
    sides: 4,
    renderType: Shape3DType.rhombus3d,
    realWorldEmojis: ['💎', '🪁', '♦️'],
    distractorEmojis: ['⭐', '🧊', '🔺'],
  ),
  ShapeMeta(
    id: 'pentagon',
    nameArabic: 'خماسي',
    sides: 5,
    renderType: Shape3DType.pentagonPrism,
    realWorldEmojis: ['🏠', '⚾'],
    distractorEmojis: ['🧊', '⭐', '💎'],
  ),
  ShapeMeta(
    id: 'hexagon',
    nameArabic: 'سداسي',
    sides: 6,
    renderType: Shape3DType.hexagonPrism,
    realWorldEmojis: ['🍯', '⚙️', '❄️'],
    distractorEmojis: ['🧊', '🔺', '💎'],
  ),
];

ShapeMeta shapeById(String id) => kShapes.firstWhere((s) => s.id == id);
