// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receita.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceitaAdapter extends TypeAdapter<Receita> {
  @override
  final int typeId = 1;

  @override
  Receita read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receita(
      id: fields[0] as String,
      nome: fields[1] as String,
      ingredientes: (fields[2] as List).cast<Ingrediente>(),
      percentualGastos: fields[3] as double,
      percentualMaoDeObra: fields[4] as double,
      rendimento: fields[5] as double,
      unidadeRendimento: fields[6] as String,
      imagemUrl: fields[7] as String?,
      dataUltimaAtualizacao: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Receita obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.ingredientes)
      ..writeByte(3)
      ..write(obj.percentualGastos)
      ..writeByte(4)
      ..write(obj.percentualMaoDeObra)
      ..writeByte(5)
      ..write(obj.rendimento)
      ..writeByte(6)
      ..write(obj.unidadeRendimento)
      ..writeByte(7)
      ..write(obj.imagemUrl)
      ..writeByte(8)
      ..write(obj.dataUltimaAtualizacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceitaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
