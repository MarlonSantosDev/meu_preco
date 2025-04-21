import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/repositories/receita_repository.dart';

class ObterTodasReceitasUseCase {
  final ReceitaRepository repository;

  ObterTodasReceitasUseCase(this.repository);

  Future<List<Receita>> executar() async {
    return await repository.obterTodas();
  }
}

class ObterReceitaPorIdUseCase {
  final ReceitaRepository repository;

  ObterReceitaPorIdUseCase(this.repository);

  Future<Receita?> executar(String id) async {
    return await repository.obterPorId(id);
  }
}

class SalvarReceitaUseCase {
  final ReceitaRepository repository;

  SalvarReceitaUseCase(this.repository);

  Future<void> executar(Receita receita) async {
    await repository.salvar(receita);
  }
}

class AtualizarReceitaUseCase {
  final ReceitaRepository repository;

  AtualizarReceitaUseCase(this.repository);

  Future<void> executar(Receita receita) async {
    await repository.atualizar(receita);
  }
}

class RemoverReceitaUseCase {
  final ReceitaRepository repository;

  RemoverReceitaUseCase(this.repository);

  Future<void> executar(String id) async {
    await repository.remover(id);
  }
}

class CalcularPrecoReceitaUseCase {
  Future<double> executar(Receita receita) async {
    return receita.valorTotal;
  }
}

class CalcularPrecoUnitarioReceitaUseCase {
  Future<double> executar(Receita receita) async {
    return receita.valorPorUnidade;
  }
}
