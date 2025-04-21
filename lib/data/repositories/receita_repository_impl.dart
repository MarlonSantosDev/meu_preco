import 'package:meu_preco/data/datasources/hive_datasource.dart';
import 'package:meu_preco/data/models/receita_dto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/repositories/receita_repository.dart';

class ReceitaRepositoryImpl implements ReceitaRepository {
  final HiveDataSource dataSource;

  ReceitaRepositoryImpl(this.dataSource);

  @override
  Future<List<Receita>> obterTodas() async {
    final receitas = await dataSource.obterTodasReceitas();
    return receitas.map((receita) {
      final dto = ReceitaDTO.fromEntity(receita);
      return dto.toEntity();
    }).toList();
  }

  @override
  Future<Receita?> obterPorId(String id) async {
    final receita = await dataSource.obterReceitaPorId(id);
    if (receita != null) {
      final dto = ReceitaDTO.fromEntity(receita);
      return dto.toEntity();
    }
    return null;
  }

  @override
  Future<void> salvar(Receita receita) async {
    final dto = ReceitaDTO.fromEntity(receita);
    await dataSource.salvarReceita(dto.toEntity());
  }

  @override
  Future<void> atualizar(Receita receita) async {
    final dto = ReceitaDTO.fromEntity(receita);
    await dataSource.atualizarReceita(dto.toEntity());
  }

  @override
  Future<void> remover(String id) async {
    await dataSource.removerReceita(id);
  }
}
