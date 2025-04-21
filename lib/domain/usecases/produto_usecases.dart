import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/repositories/produto_repository.dart';

class ObterTodosProdutosUseCase {
  final ProdutoRepository repository;

  ObterTodosProdutosUseCase(this.repository);

  Future<List<Produto>> executar() async {
    return await repository.obterTodos();
  }
}

class ObterProdutoPorIdUseCase {
  final ProdutoRepository repository;

  ObterProdutoPorIdUseCase(this.repository);

  Future<Produto?> executar(String id) async {
    return await repository.obterPorId(id);
  }
}

class SalvarProdutoUseCase {
  final ProdutoRepository repository;

  SalvarProdutoUseCase(this.repository);

  Future<void> executar(Produto produto) async {
    await repository.salvar(produto);
  }
}

class AtualizarProdutoUseCase {
  final ProdutoRepository repository;

  AtualizarProdutoUseCase(this.repository);

  Future<void> executar(Produto produto) async {
    await repository.atualizar(produto);
  }
}

class RemoverProdutoUseCase {
  final ProdutoRepository repository;

  RemoverProdutoUseCase(this.repository);

  Future<void> executar(String id) async {
    await repository.remover(id);
  }
}
