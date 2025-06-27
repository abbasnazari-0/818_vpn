// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribtion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscribtionModelAdapter extends TypeAdapter<SubscribtionModel> {
  @override
  final int typeId = 1;

  @override
  SubscribtionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscribtionModel(
      planName: fields[1] as String,
      start: fields[2] as String,
      end: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubscribtionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.planName)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscribtionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
