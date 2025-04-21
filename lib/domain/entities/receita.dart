import 'package:hive/hive.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';

part 'receita.g.dart';

@HiveType(typeId: 1)
class Receita {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  List<Ingrediente> ingredientes;

  @HiveField(3)
  double percentualGastos;

  @HiveField(4)
  double percentualMaoDeObra;

  @HiveField(5)
  double rendimento;

  @HiveField(6)
  String unidadeRendimento; // unidade, kg, L, etc.

  @HiveField(7)
  String? imagemUrl; // Campo para armazenar o path ou url da imagem

  @HiveField(8)
  DateTime dataUltimaAtualizacao;

  Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    this.percentualGastos = 0.2, // 20% padrão
    this.percentualMaoDeObra = 0.2, // 20% padrão
    required this.rendimento,
    required this.unidadeRendimento,
    this.imagemUrl,
    DateTime? dataUltimaAtualizacao,
  }) : this.dataUltimaAtualizacao = dataUltimaAtualizacao ?? DateTime.now();

  // Custo total dos ingredientes (Valor da Receita)
  double get custoIngredientes {
    return ingredientes.fold(0, (sum, ingrediente) => sum + ingrediente.custoTotal);
  }

  // Valor dos gastos "escondidos" (porcentagem sobre o custo dos ingredientes)
  double get valorGastosEscondidos {
    return custoIngredientes * percentualGastos;
  }

  // Valor da mão de obra (porcentagem sobre o custo dos ingredientes)
  double get valorMaoDeObra {
    return custoIngredientes * percentualMaoDeObra;
  }

  // Soma dos percentuais aplicados (gastos + mão de obra)
  double get percentualTotal {
    return percentualGastos + percentualMaoDeObra;
  }

  // Valor calculado dos percentuais (gastos + mão de obra)
  double get valorPercentuais {
    return custoIngredientes * percentualTotal;
  }

  // Valor do lucro (100% sobre o custo dos ingredientes)
  double get valorLucro {
    return custoIngredientes;
  }

  // Valor total da receita (ingredientes + gastos + mão de obra + lucro)
  double get valorTotal {
    return custoIngredientes + valorPercentuais + valorLucro;
  }

  // Valor por unidade de rendimento (kg, unidade, etc.)
  double get valorPorUnidade {
    return valorTotal / rendimento;
  }
}
