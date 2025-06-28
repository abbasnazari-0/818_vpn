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
      start: fields[2] as String?,
      end: fields[3] as String?,
      mass: fields[4] as MassSubModel?,
    );
  }

  @override
  void write(BinaryWriter writer, SubscribtionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.planName)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.mass);
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

class MassSubModelAdapter extends TypeAdapter<MassSubModel> {
  @override
  final int typeId = 3;

  @override
  MassSubModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MassSubModel(
      usedVolume: fields[1] as String,
      totalVolume: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MassSubModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.usedVolume)
      ..writeByte(2)
      ..write(obj.totalVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MassSubModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
