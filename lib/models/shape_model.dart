import 'package:hive/hive.dart';

part 'shape_model.g.dart';

/// Which primitive to use when rendering the pseudo-3D CustomPainter shape.
enum Shape3DType {
  sphere,   // دائرة
  cube,     // مربع
  pyramid,  // مثلث
  cuboid,   // مستطيل
  ellipsoid,// بيضاوي
  star3d,   // نجمة
  heart3d,  // قلب
  rhombus3d,// معين
  pentagonPrism, // خماسي
  hexagonPrism,  // سداسي
}

@HiveType(typeId: 1)
class ShapeUnit extends HiveObject {
  @HiveField(0)
  final String id; // e.g. 'circle'

  @HiveField(1)
  final String nameArabic; // دائرة

  @HiveField(2)
  final int sides; // 0 for circle/oval/heart

  @HiveField(3)
  final String emojiRealWorldOptions; // comma separated emoji for "find in real life"

  ShapeUnit({
    required this.id,
    required this.nameArabic,
    required this.sides,
    required this.emojiRealWorldOptions,
  });
}

/// Static, non-Hive metadata paired with each ShapeUnit (rendering + real-world matches).
class ShapeMeta {
  final String id;
  final String nameArabic;
  final int sides; // -1 means "no sides quiz" (circle, oval, heart)
  final Shape3DType renderType;
  final List<String> realWorldEmojis; // correct matches
  final List<String> distractorEmojis; // wrong matches for the "find it" activity

  const ShapeMeta({
    required this.id,
    required this.nameArabic,
    required this.sides,
    required this.renderType,
    required this.realWorldEmojis,
    required this.distractorEmojis,
  });
}
