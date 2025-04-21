import 'package:hive/hive.dart';
import 'package:meu_preco/core/hive_init.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';

class HiveDataSource {
  static const String produtosBoxName = HiveInit.produtosBoxName;
  static const String receitasBoxName = HiveInit.receitasBoxName;

  static Future<void> init() async {
    await HiveInit.init();
  }

  // Métodos para Produtos
  Future<List<Produto>> obterTodosProdutos() async {
    final box = Hive.box<Produto>(produtosBoxName);
    return box.values.toList();
  }

  Future<Produto?> obterProdutoPorId(String id) async {
    final box = Hive.box<Produto>(produtosBoxName);
    return box.get(id);
  }

  Future<void> salvarProduto(Produto produto) async {
    final box = Hive.box<Produto>(produtosBoxName);
    await box.put(produto.id, produto);
  }

  Future<void> atualizarProduto(Produto produto) async {
    final box = Hive.box<Produto>(produtosBoxName);
    await box.put(produto.id, produto);
  }

  Future<void> removerProduto(String id) async {
    final box = Hive.box<Produto>(produtosBoxName);
    await box.delete(id);
  }

  // Métodos para Receitas
  Future<List<Receita>> obterTodasReceitas() async {
    final box = Hive.box<Receita>(receitasBoxName);
    return box.values.toList();
  }

  Future<Receita?> obterReceitaPorId(String id) async {
    final box = Hive.box<Receita>(receitasBoxName);
    return box.get(id);
  }

  Future<void> salvarReceita(Receita receita) async {
    final box = Hive.box<Receita>(receitasBoxName);
    await box.put(receita.id, receita);
  }

  Future<void> atualizarReceita(Receita receita) async {
    final box = Hive.box<Receita>(receitasBoxName);
    await box.put(receita.id, receita);
  }

  Future<void> removerReceita(String id) async {
    final box = Hive.box<Receita>(receitasBoxName);
    await box.delete(id);
  }
}
