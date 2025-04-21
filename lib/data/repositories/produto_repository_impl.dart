import 'package:meu_preco/data/datasources/hive_datasource.dart';
import 'package:meu_preco/data/models/produto_dto.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/repositories/produto_repository.dart';

class ProdutoRepositoryImpl implements ProdutoRepository {
  final HiveDataSource dataSource;

  ProdutoRepositoryImpl(this.dataSource);

  @override
  Future<List<Produto>> obterTodos() async {
    final produtos = await dataSource.obterTodosProdutos();
    return produtos.map((produto) {
      final dto = ProdutoDTO.fromEntity(produto);
      return dto.toEntity();
    }).toList();
  }

  @override
  Future<Produto?> obterPorId(String id) async {
    final produto = await dataSource.obterProdutoPorId(id);
    if (produto != null) {
      final dto = ProdutoDTO.fromEntity(produto);
      return dto.toEntity();
    }
    return null;
  }

  @override
  Future<void> salvar(Produto produto) async {
    final dto = ProdutoDTO.fromEntity(produto);
    await dataSource.salvarProduto(dto.toEntity());
  }

  @override
  Future<void> atualizar(Produto produto) async {
    final dto = ProdutoDTO.fromEntity(produto);
    await dataSource.atualizarProduto(dto.toEntity());
  }

  @override
  Future<void> remover(String id) async {
    await dataSource.removerProduto(id);
  }
}
