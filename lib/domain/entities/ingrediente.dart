import 'package:hive/hive.dart';
import 'package:meu_preco/domain/entities/produto.dart';

part 'ingrediente.g.dart';

@HiveType(typeId: 2)
class Ingrediente {
  @HiveField(0)
  String id;

  @HiveField(1)
  Produto produto;

  @HiveField(2)
  double quantidade;

  @HiveField(3)
  String unidade; // kg, g, L, ml, unidade, colher, xícara, etc.

  Ingrediente({required this.id, required this.produto, required this.quantidade, required this.unidade});

  // Calcula o custo do ingrediente baseado no preço unitário do produto
  double get custoTotal {
    // Converte a unidade do ingrediente para a unidade do produto se necessário
    double quantidadeConvertida = converterQuantidade();
    return produto.precoUnitario * quantidadeConvertida;
  }

  // Método para converter a quantidade do ingrediente para a unidade do produto
  // Implementação simplificada, apenas para os casos mais comuns
  double converterQuantidade() {
    // Se a unidade do ingrediente for igual à do produto, não precisa converter
    if (unidade == produto.unidade) {
      return quantidade;
    }

    // Exemplos de conversões básicas
    // De g para kg
    if (unidade == 'g' && produto.unidade == 'kg') {
      return quantidade / 1000;
    }
    // De kg para g
    if (unidade == 'kg' && produto.unidade == 'g') {
      return quantidade * 1000;
    }
    // De ml para L
    if (unidade == 'ml' && produto.unidade == 'L') {
      return quantidade / 1000;
    }
    // De L para ml
    if (unidade == 'L' && produto.unidade == 'ml') {
      return quantidade * 1000;
    }

    // Outras conversões podem ser adicionadas conforme necessário

    // Se não houver conversão definida, retorna a quantidade original
    // Em uma implementação real, você poderia lançar um erro ou mostrar um aviso
    return quantidade;
  }

  @override
  String toString() => '${produto.nome} - $quantidade $unidade';
}
