// GENERATED CODE - mirrors what `flutter pub run build_runner build` would
// produce for ChapterProgress. Regenerate with build_runner if the model changes.
part of 'chapter_model.dart';

class ChapterProgressAdapter extends TypeAdapter<ChapterProgress> {
  @override
  final int typeId = 2;

  @override
  ChapterProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterProgress(
      chapterNumber: fields[0] as int,
      starsEarned: fields[1] as int,
      isUnlocked: fields[2] as bool,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterProgress obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.chapterNumber)
      ..writeByte(1)
      ..write(obj.starsEarned)
      ..writeByte(2)
      ..write(obj.isUnlocked)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterProgressAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
