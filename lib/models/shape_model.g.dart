// GENERATED CODE - mirrors what `flutter pub run build_runner build` would
// produce for ShapeUnit. Regenerate with build_runner if the model changes.
part of 'shape_model.dart';

class ShapeUnitAdapter extends TypeAdapter<ShapeUnit> {
  @override
  final int typeId = 1;

  @override
  ShapeUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShapeUnit(
      id: fields[0] as String,
      nameArabic: fields[1] as String,
      sides: fields[2] as int,
      emojiRealWorldOptions: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShapeUnit obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameArabic)
      ..writeByte(2)
      ..write(obj.sides)
      ..writeByte(3)
      ..write(obj.emojiRealWorldOptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeUnitAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
