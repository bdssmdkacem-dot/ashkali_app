import '../models/shape_model.dart';

const _objBase = 'assets/images/objects';
const _iconBase = 'assets/images/shape_icons';

/// The 10 shapes of أشكالي, ordered easiest (0 sides) -> most complex.
/// This order drives chapters 1-3, 5-7, 9-12 (see chapters_data.dart).
/// Real-world matches now use illustrated PNGs (assets/images/objects/)
/// instead of emoji, one-to-one replacement of the original emoji set.
const List<ShapeMeta> kShapes = [
  ShapeMeta(
    id: 'circle',
    iconAsset: '$_iconBase/circle.png',
    nameArabic: 'دائرة',
    sides: -1,
    renderType: Shape3DType.sphere,
    // was: ⚽ 🍪 🌕 🎡
    realWorldImages: ['$_objBase/ball.png', '$_objBase/cookie.png', '$_objBase/moon.png', '$_objBase/ferriswheel.png'],
    // was: 📐 🧊 🍕
    distractorImages: ['$_objBase/setsquare.png', '$_objBase/icecube.png', '$_objBase/pizza.png'],
  ),
  ShapeMeta(
    id: 'square',
    iconAsset: '$_iconBase/square.png',
    nameArabic: 'مربع',
    sides: 4,
    renderType: Shape3DType.cube,
    // was: 🧊 🎲 🪟 ♟️
    realWorldImages: ['$_objBase/icecube.png', '$_objBase/dice.png', '$_objBase/window.png', '$_objBase/chesspawn.png'],
    // was: ⚽ 🍕 ⭐
    distractorImages: ['$_objBase/ball.png', '$_objBase/pizza.png', '$_objBase/star.png'],
  ),
  ShapeMeta(
    id: 'triangle',
    iconAsset: '$_iconBase/triangle.png',
    nameArabic: 'مثلث',
    sides: 3,
    renderType: Shape3DType.pyramid,
    // was: 🍕 ⛰️ 🚩 🔺
    realWorldImages: ['$_objBase/pizza.png', '$_objBase/mountain.png', '$_objBase/flag.png', '$_objBase/diamondsuit.png'],
    // was: 🧊 ⚽ 🍩
    distractorImages: ['$_objBase/icecube.png', '$_objBase/ball.png', '$_objBase/donut.png'],
  ),
  ShapeMeta(
    id: 'rectangle',
    iconAsset: '$_iconBase/rectangle.png',
    nameArabic: 'مستطيل',
    sides: 4,
    renderType: Shape3DType.cuboid,
    // was: 📱 🚪 📕 🧱
    realWorldImages: ['$_objBase/phone.png', '$_objBase/door.png', '$_objBase/book.png', '$_objBase/brick.png'],
    // was: ⚽ 🔺 ⭐
    distractorImages: ['$_objBase/ball.png', '$_objBase/diamondsuit.png', '$_objBase/star.png'],
  ),
  ShapeMeta(
    id: 'oval',
    iconAsset: '$_iconBase/oval.png',
    nameArabic: 'بيضاوي',
    sides: -1,
    renderType: Shape3DType.ellipsoid,
    // was: 🥚 🍈 🏉 🐟
    realWorldImages: ['$_objBase/egg.png', '$_objBase/melon.png', '$_objBase/rugby.png', '$_objBase/fish.png'],
    // was: 🧊 🔺 📕
    distractorImages: ['$_objBase/icecube.png', '$_objBase/diamondsuit.png', '$_objBase/book.png'],
  ),
  ShapeMeta(
    id: 'star',
    iconAsset: '$_iconBase/star.png',
    nameArabic: 'نجمة',
    sides: 5,
    renderType: Shape3DType.star3d,
    // was: ⭐ 🌟 ✨ 🕋
    realWorldImages: ['$_objBase/star.png', '$_objBase/star.png', '$_objBase/sparkle.png', '$_objBase/kaaba.png'],
    // was: ⚽ 🧊 🥚
    distractorImages: ['$_objBase/ball.png', '$_objBase/icecube.png', '$_objBase/egg.png'],
  ),
  ShapeMeta(
    id: 'heart',
    iconAsset: '$_iconBase/heart.png',
    nameArabic: 'قلب',
    sides: -1,
    renderType: Shape3DType.heart3d,
    // was: ❤️ 💝 💌
    realWorldImages: ['$_objBase/heart.png', '$_objBase/giftheart.png', '$_objBase/loveletter.png'],
    // was: ⭐ 🧊 🥚
    distractorImages: ['$_objBase/star.png', '$_objBase/icecube.png', '$_objBase/egg.png'],
  ),
  ShapeMeta(
    id: 'rhombus',
    iconAsset: '$_iconBase/rhombus.png',
    nameArabic: 'معين',
    sides: 4,
    renderType: Shape3DType.rhombus3d,
    // was: 💎 🪁 ♦️
    realWorldImages: ['$_objBase/diamond.png', '$_objBase/kite.png', '$_objBase/diamondsuit.png'],
    // was: ⭐ 🧊 🔺
    distractorImages: ['$_objBase/star.png', '$_objBase/icecube.png', '$_objBase/diamondsuit.png'],
  ),
  ShapeMeta(
    id: 'pentagon',
    iconAsset: '$_iconBase/pentagon.png',
    nameArabic: 'خماسي',
    sides: 5,
    renderType: Shape3DType.pentagonPrism,
    // was: 🏠 ⚾
    realWorldImages: ['$_objBase/house.png', '$_objBase/baseball.png'],
    // was: 🧊 ⭐ 💎
    distractorImages: ['$_objBase/icecube.png', '$_objBase/star.png', '$_objBase/diamond.png'],
  ),
  ShapeMeta(
    id: 'hexagon',
    iconAsset: '$_iconBase/hexagon.png',
    nameArabic: 'سداسي',
    sides: 6,
    renderType: Shape3DType.hexagonPrism,
    // was: 🍯 ⚙️ ❄️
    realWorldImages: ['$_objBase/honey.png', '$_objBase/gear.png', '$_objBase/snowflake.png'],
    // was: 🧊 🔺 💎
    distractorImages: ['$_objBase/icecube.png', '$_objBase/diamondsuit.png', '$_objBase/diamond.png'],
  ),
];

ShapeMeta shapeById(String id) => kShapes.firstWhere((s) => s.id == id);
