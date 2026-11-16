// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertAdapter extends TypeAdapter<Alert> {
  @override
  final typeId = 5;

  @override
  Alert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alert(
      id: fields[0] as String,
      content: fields[1] as String,
      title: fields[6] == null ? '' : fields[6] as String,
      dismissible: fields[7] == null ? true : fields[7] as bool,
      dismissedBy: fields[8] == null ? [] : (fields[8] as List).cast<String>(),
      actionLabel: fields[9] == null ? '' : fields[9] as String,
      actionRoute: fields[10] == null ? '' : fields[10] as String,
      kind: fields[12] == null ? AlertKind.standard : fields[12] as AlertKind,
      startAt: fields[2] as DateTime,
      endAt: fields[3] as DateTime,
      created: fields[4] as DateTime,
      updated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Alert obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.startAt)
      ..writeByte(3)
      ..write(obj.endAt)
      ..writeByte(4)
      ..write(obj.created)
      ..writeByte(5)
      ..write(obj.updated)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.dismissible)
      ..writeByte(8)
      ..write(obj.dismissedBy)
      ..writeByte(9)
      ..write(obj.actionLabel)
      ..writeByte(10)
      ..write(obj.actionRoute)
      ..writeByte(12)
      ..write(obj.kind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertKindAdapter extends TypeAdapter<AlertKind> {
  @override
  final typeId = 7;

  @override
  AlertKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertKind.standard;
      case 1:
        return AlertKind.anniversary;
      case 2:
        return AlertKind.birthday;
      default:
        return AlertKind.standard;
    }
  }

  @override
  void write(BinaryWriter writer, AlertKind obj) {
    switch (obj) {
      case AlertKind.standard:
        writer.writeByte(0);
      case AlertKind.anniversary:
        writer.writeByte(1);
      case AlertKind.birthday:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
