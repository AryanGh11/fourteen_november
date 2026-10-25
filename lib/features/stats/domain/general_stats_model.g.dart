// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeneralStatsAdapter extends TypeAdapter<GeneralStats> {
  @override
  final typeId = 6;

  @override
  GeneralStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneralStats(
      id: fields[0] as String,
      lastHugAt: fields[1] as DateTime,
      togetherSince: fields[2] as DateTime,
      created: fields[3] as DateTime,
      updated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GeneralStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lastHugAt)
      ..writeByte(2)
      ..write(obj.togetherSince)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
