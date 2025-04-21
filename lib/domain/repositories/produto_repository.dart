import 'package:meu_preco/domain/entities/produto.dart';

abstract class ProdutoRepository {
  Future<List<Produto>> obterTodos();
  Future<Produto?> obterPorId(String id);
  Future<void> salvar(Produto produto);
  Future<void> atualizar(Produto produto);
  Future<void> remover(String id);
}
