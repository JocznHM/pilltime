// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      medicineName: fields[0] as String,
      dose: fields[1] as String,
      intervalMinutes: fields[2] as int,
      id: fields[3] as int,
      firstDoseTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.medicineName)
      ..writeByte(1)
      ..write(obj.dose)
      ..writeByte(2)
      ..write(obj.intervalMinutes)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.firstDoseTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
