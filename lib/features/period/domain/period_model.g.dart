// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodAdapter extends TypeAdapter<Period> {
  @override
  final typeId = 8;

  @override
  Period read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Period(
      id: fields[0] as String,
      userId: fields[1] as String,
      periodDate: fields[2] as DateTime,
      daysFromPrevious: fields[3] as int?,
      cycleLength: fields[4] as int,
      created: fields[5] as DateTime,
      updated: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Period obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.periodDate)
      ..writeByte(3)
      ..write(obj.daysFromPrevious)
      ..writeByte(4)
      ..write(obj.cycleLength)
      ..writeByte(5)
      ..write(obj.created)
      ..writeByte(6)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}