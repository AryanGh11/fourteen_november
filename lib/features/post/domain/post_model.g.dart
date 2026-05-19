// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 4;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      id: fields[0] as String,
      userId: fields[1] as String,
      attachmentPath: fields[2] as String,
      description: fields[3] as String,
      likesBy: (fields[4] as List).cast<String>(),
      commentsIds: (fields[5] as List).cast<String>(),
      created: fields[6] as DateTime,
      updated: fields[7] as DateTime,
      attachmentUrl: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.attachmentPath)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.likesBy)
      ..writeByte(5)
      ..write(obj.commentsIds)
      ..writeByte(6)
      ..write(obj.created)
      ..writeByte(7)
      ..write(obj.updated)
      ..writeByte(8)
      ..write(obj.attachmentUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
