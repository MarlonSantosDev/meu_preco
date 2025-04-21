import 'package:meu_preco/domain/entities/produto.dart';

class ProdutoDTO {
  final String id;
  final String nome;
  final double preco;
  final double quantidade;
  final String unidade;

  ProdutoDTO({required this.id, required this.nome, required this.preco, required this.quantidade, required this.unidade});

  // Converter de Entidade para DTO
  factory ProdutoDTO.fromEntity(Produto produto) {
    return ProdutoDTO(id: produto.id, nome: produto.nome, preco: produto.preco, quantidade: produto.quantidade, unidade: produto.unidade);
  }

  // Converter de DTO para Entidade
  Produto toEntity() {
    return Produto(id: id, nome: nome, preco: preco, quantidade: quantidade, unidade: unidade);
  }

  // Converter de Map para DTO
  factory ProdutoDTO.fromMap(Map<String, dynamic> map) {
    return ProdutoDTO(id: map['id'] as String, nome: map['nome'] as String, preco: map['preco'] as double, quantidade: map['quantidade'] as double, unidade: map['unidade'] as String);
  }

  // Converter de DTO para Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'preco': preco, 'quantidade': quantidade, 'unidade': unidade};
  }
}
