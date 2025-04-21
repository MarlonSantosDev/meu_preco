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
  String unidade; // kg, g, L, ml, unidade, colher de sopa, colher de chá, xícara, etc.

  @HiveField(4)
  String? fracao; // Para armazenar valores como 1/2, 1/4, etc.

  Ingrediente({required this.id, required this.produto, required this.quantidade, required this.unidade, this.fracao});

  // Calcula o custo do ingrediente baseado no preço unitário do produto
  double get custoTotal {
    // Converte a unidade do ingrediente para a unidade do produto se necessário
    double quantidadeConvertida = converterQuantidade();
    return produto.precoUnitario * quantidadeConvertida;
  }

  // Método para converter a quantidade do ingrediente para a unidade do produto
  double converterQuantidade() {
    // Se a unidade do ingrediente for igual à do produto, não precisa converter
    if (unidade == produto.unidade) {
      return quantidade;
    }

    // Conversões básicas de peso e volume
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

    // Conversões para medidas de colher e xícara
    // Xícara para ml (1 xícara = 240 ml)
    if (unidade == 'xícara' && (produto.unidade == 'ml' || produto.unidade == 'g')) {
      return quantidade * 240;
    }
    // Xícara para L
    if (unidade == 'xícara' && produto.unidade == 'L') {
      return quantidade * 0.24;
    }
    // Colher de sopa para ml (1 colher de sopa = 15 ml)
    if (unidade == 'colher de sopa' && (produto.unidade == 'ml' || produto.unidade == 'g')) {
      return quantidade * 15;
    }
    // Colher de sopa para L
    if (unidade == 'colher de sopa' && produto.unidade == 'L') {
      return quantidade * 0.015;
    }
    // Colher de chá para ml (1 colher de chá = 5 ml)
    if (unidade == 'colher de chá' && (produto.unidade == 'ml' || produto.unidade == 'g')) {
      return quantidade * 5;
    }
    // Colher de chá para L
    if (unidade == 'colher de chá' && produto.unidade == 'L') {
      return quantidade * 0.005;
    }

    // Se não houver conversão definida, retorna a quantidade original
    return quantidade;
  }

  // Método para converter frações para decimal
  static double converterFracao(String fracao) {
    if (fracao.contains('/')) {
      final partes = fracao.split('/');
      if (partes.length == 2) {
        final numerador = double.tryParse(partes[0]) ?? 0;
        final denominador = double.tryParse(partes[1]) ?? 1;
        if (denominador != 0) {
          return numerador / denominador;
        }
      }
    }
    return 0;
  }

  @override
  String toString() {
    if (fracao != null && fracao!.isNotEmpty) {
      return '${produto.nome} - $fracao $unidade';
    }
    return '${produto.nome} - $quantidade $unidade';
  }
}
