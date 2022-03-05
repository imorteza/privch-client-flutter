// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shadowsocks.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShadowsocksAdapter extends TypeAdapter<Shadowsocks> {
  @override
  final int typeId = 1;

  @override
  Shadowsocks read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shadowsocks(
      encrypt: fields[0] as String,
      password: fields[1] as String,
      address: fields[2] as String,
      port: fields[3] as int,
      name: fields[4] as String?,
      order: fields[6] as int?,
      geoLocation: fields[7] as String?,
      responseTime: fields[8] as int?,
    )..modified = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, Shadowsocks obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.encrypt)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.modified)
      ..writeByte(6)
      ..write(obj.order)
      ..writeByte(7)
      ..write(obj.geoLocation)
      ..writeByte(8)
      ..write(obj.responseTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowsocksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
