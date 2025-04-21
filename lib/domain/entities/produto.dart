import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  double preco;

  @HiveField(3)
  double quantidade;

  @HiveField(4)
  String unidade; // kg, L, g, ml, etc.

  @HiveField(5)
  String? imagemUrl; // Campo para armazenar o path ou url da imagem

  Produto({required this.id, required this.nome, required this.preco, required this.quantidade, required this.unidade, this.imagemUrl});

  double get precoUnitario => preco / quantidade;

  @override
  String toString() => '$nome - $quantidade $unidade - R\$ $preco';
}
