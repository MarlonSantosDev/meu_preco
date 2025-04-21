import 'package:meu_preco/data/models/ingrediente_dto.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';
import 'package:meu_preco/domain/entities/receita.dart';

class ReceitaDTO {
  final String id;
  final String nome;
  final List<IngredienteDTO> ingredientes;
  final double percentualGastos;
  final double percentualMaoDeObra;
  final double rendimento;
  final String unidadeRendimento;

  ReceitaDTO({required this.id, required this.nome, required this.ingredientes, required this.percentualGastos, required this.percentualMaoDeObra, required this.rendimento, required this.unidadeRendimento});

  // Converter de Entidade para DTO
  factory ReceitaDTO.fromEntity(Receita receita) {
    return ReceitaDTO(id: receita.id, nome: receita.nome, ingredientes: receita.ingredientes.map((ingrediente) => IngredienteDTO.fromEntity(ingrediente)).toList(), percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento);
  }

  // Converter de DTO para Entidade
  Receita toEntity() {
    return Receita(id: id, nome: nome, ingredientes: ingredientes.map((ingredienteDTO) => ingredienteDTO.toEntity()).toList(), percentualGastos: percentualGastos, percentualMaoDeObra: percentualMaoDeObra, rendimento: rendimento, unidadeRendimento: unidadeRendimento);
  }

  // Converter de Map para DTO
  factory ReceitaDTO.fromMap(Map<String, dynamic> map) {
    return ReceitaDTO(id: map['id'] as String, nome: map['nome'] as String, ingredientes: (map['ingredientes'] as List<dynamic>).map((ingredienteMap) => IngredienteDTO.fromMap(ingredienteMap as Map<String, dynamic>)).toList(), percentualGastos: map['percentualGastos'] as double, percentualMaoDeObra: map['percentualMaoDeObra'] as double, rendimento: map['rendimento'] as double, unidadeRendimento: map['unidadeRendimento'] as String);
  }

  // Converter de DTO para Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'ingredientes': ingredientes.map((ingrediente) => ingrediente.toMap()).toList(), 'percentualGastos': percentualGastos, 'percentualMaoDeObra': percentualMaoDeObra, 'rendimento': rendimento, 'unidadeRendimento': unidadeRendimento};
  }
}
