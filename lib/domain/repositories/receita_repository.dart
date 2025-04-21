import 'package:meu_preco/domain/entities/receita.dart';

abstract class ReceitaRepository {
  Future<List<Receita>> obterTodas();
  Future<Receita?> obterPorId(String id);
  Future<void> salvar(Receita receita);
  Future<void> atualizar(Receita receita);
  Future<void> remover(String id);
}
