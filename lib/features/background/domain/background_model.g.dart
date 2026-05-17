// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BackgroundAdapter extends TypeAdapter<Background> {
  @override
  final int typeId = 2;

  @override
  Background read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Background(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      created: fields[6] as DateTime,
      updated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Background obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.created)
      ..writeByte(7)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
