// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingAdapter extends TypeAdapter<Setting> {
  @override
  final int typeId = 0;

  @override
  Setting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setting()
      ..windowX = fields[0] as int
      ..windowY = fields[1] as int
      ..windowW = fields[2] as int
      ..windowH = fields[3] as int
      ..windowTopMost = fields[4] as bool
      ..serverSelId = fields[5] as String?
      ..sortModeIndex = fields[6] as int
      ..themeModeIndex = fields[7] as int
      ..httpPort = fields[8] as int
      ..socksPort = fields[9] as int
      ..dnsLocalPort = fields[10] as int
      ..dnsRemoteAddress = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, Setting obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.windowX)
      ..writeByte(1)
      ..write(obj.windowY)
      ..writeByte(2)
      ..write(obj.windowW)
      ..writeByte(3)
      ..write(obj.windowH)
      ..writeByte(4)
      ..write(obj.windowTopMost)
      ..writeByte(5)
      ..write(obj.serverSelId)
      ..writeByte(6)
      ..write(obj.sortModeIndex)
      ..writeByte(7)
      ..write(obj.themeModeIndex)
      ..writeByte(8)
      ..write(obj.httpPort)
      ..writeByte(9)
      ..write(obj.socksPort)
      ..writeByte(10)
      ..write(obj.dnsLocalPort)
      ..writeByte(11)
      ..write(obj.dnsRemoteAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
