import 'package:meu_preco/data/models/produto_dto.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';

class IngredienteDTO {
  final String id;
  final ProdutoDTO produto;
  final double quantidade;
  final String unidade;
  final String? fracao;

  IngredienteDTO({
    required this.id,
    required this.produto,
    required this.quantidade,
    required this.unidade,
    this.fracao,
  });

  // Converter de Entidade para DTO
  factory IngredienteDTO.fromEntity(Ingrediente ingrediente) {
    return IngredienteDTO(
      id: ingrediente.id,
      produto: ProdutoDTO.fromEntity(ingrediente.produto),
      quantidade: ingrediente.quantidade,
      unidade: ingrediente.unidade,
      fracao: ingrediente.fracao,
    );
  }

  // Converter de DTO para Entidade
  Ingrediente toEntity() {
    return Ingrediente(id: id, produto: produto.toEntity(), quantidade: quantidade, unidade: unidade, fracao: fracao);
  }

  // Converter de Map para DTO
  factory IngredienteDTO.fromMap(Map<String, dynamic> map) {
    return IngredienteDTO(
      id: map['id'] as String,
      produto: ProdutoDTO.fromMap(map['produto'] as Map<String, dynamic>),
      quantidade: map['quantidade'] as double,
      unidade: map['unidade'] as String,
      fracao: map['fracao'] as String?,
    );
  }

  // Converter de DTO para Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'produto': produto.toMap(), 'quantidade': quantidade, 'unidade': unidade, 'fracao': fracao};
  }
}
