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

  Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    this.percentualGastos = 0.2, // 20% padrão
    this.percentualMaoDeObra = 0.2, // 20% padrão
    required this.rendimento,
    required this.unidadeRendimento,
  });

  // Custo total dos ingredientes
  double get custoIngredientes {
    return ingredientes.fold(0, (sum, ingrediente) => sum + ingrediente.custoTotal);
  }

  // Custo total com gastos "escondidos"
  double get custoComGastos {
    return custoIngredientes * (1 + percentualGastos);
  }

  // Valor final com mão de obra
  double get valorTotal {
    double valorBase = custoComGastos / (1 - percentualMaoDeObra);
    return valorBase;
  }

  // Valor por unidade de rendimento (kg, unidade, etc.)
  double get valorPorUnidade {
    return valorTotal / rendimento;
  }
}
