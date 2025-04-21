// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingrediente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredienteAdapter extends TypeAdapter<Ingrediente> {
  @override
  final int typeId = 2;

  @override
  Ingrediente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingrediente(
      id: fields[0] as String,
      produto: fields[1] as Produto,
      quantidade: fields[2] as double,
      unidade: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ingrediente obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.produto)
      ..writeByte(2)
      ..write(obj.quantidade)
      ..writeByte(3)
      ..write(obj.unidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredienteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
