import 'package:flutter/material.dart';
import 'package:meu_preco/core/utils/id_generator.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/usecases/receita_usecases.dart';

class ReceitaController extends ChangeNotifier {
  ObterTodasReceitasUseCase _obterTodasReceitasUseCase;
  ObterReceitaPorIdUseCase _obterReceitaPorIdUseCase;
  SalvarReceitaUseCase _salvarReceitaUseCase;
  AtualizarReceitaUseCase _atualizarReceitaUseCase;
  RemoverReceitaUseCase _removerReceitaUseCase;

  ReceitaController({required ObterTodasReceitasUseCase obterTodasReceitasUseCase, required ObterReceitaPorIdUseCase obterReceitaPorIdUseCase, required SalvarReceitaUseCase salvarReceitaUseCase, required AtualizarReceitaUseCase atualizarReceitaUseCase, required RemoverReceitaUseCase removerReceitaUseCase}) : _obterTodasReceitasUseCase = obterTodasReceitasUseCase, _obterReceitaPorIdUseCase = obterReceitaPorIdUseCase, _salvarReceitaUseCase = salvarReceitaUseCase, _atualizarReceitaUseCase = atualizarReceitaUseCase, _removerReceitaUseCase = removerReceitaUseCase;

  // Setters para injeção de dependência
  set obterTodasReceitasUseCase(ObterTodasReceitasUseCase useCase) {
    _obterTodasReceitasUseCase = useCase;
  }

  set obterReceitaPorIdUseCase(ObterReceitaPorIdUseCase useCase) {
    _obterReceitaPorIdUseCase = useCase;
  }

  set salvarReceitaUseCase(SalvarReceitaUseCase useCase) {
    _salvarReceitaUseCase = useCase;
  }

  set atualizarReceitaUseCase(AtualizarReceitaUseCase useCase) {
    _atualizarReceitaUseCase = useCase;
  }

  set removerReceitaUseCase(RemoverReceitaUseCase useCase) {
    _removerReceitaUseCase = useCase;
  }

  List<Receita> _receitas = [];
  List<Receita> get receitas => _receitas;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregarReceitas() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _receitas = await _obterTodasReceitasUseCase.executar();
    } catch (e) {
      _erro = 'Erro ao carregar receitas: ${e.toString()}';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> salvarReceita({required String nome, required List<Ingrediente> ingredientes, required double percentualGastos, required double percentualMaoDeObra, required double rendimento, required String unidadeRendimento, String? imagemUrl}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final receita = Receita(id: IdGenerator.generate(), nome: nome, ingredientes: ingredientes, percentualGastos: percentualGastos, percentualMaoDeObra: percentualMaoDeObra, rendimento: rendimento, unidadeRendimento: unidadeRendimento, imagemUrl: imagemUrl, dataUltimaAtualizacao: DateTime.now());

      await _salvarReceitaUseCase.executar(receita);
      await carregarReceitas();
    } catch (e) {
      _erro = 'Erro ao salvar receita: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> atualizarReceita(Receita receita) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      // Criar uma nova receita com a data de atualização atual
      final receitaAtualizada = Receita(id: receita.id, nome: receita.nome, ingredientes: receita.ingredientes, percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento, imagemUrl: receita.imagemUrl, dataUltimaAtualizacao: DateTime.now());

      await _atualizarReceitaUseCase.executar(receitaAtualizada);
      await carregarReceitas();
    } catch (e) {
      _erro = 'Erro ao atualizar receita: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> removerReceita(String id) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _removerReceitaUseCase.executar(id);
      await carregarReceitas();
    } catch (e) {
      _erro = 'Erro ao remover receita: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Receita?> obterReceitaPorId(String id) async {
    try {
      return await _obterReceitaPorIdUseCase.executar(id);
    } catch (e) {
      _erro = 'Erro ao obter receita: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> adicionarIngrediente(Receita receita, Produto produto, double quantidade, String unidade, {String? fracao}) async {
    final ingrediente = Ingrediente(id: IdGenerator.generate(), produto: produto, quantidade: quantidade, unidade: unidade, fracao: fracao);

    final novaLista = List<Ingrediente>.from(receita.ingredientes);
    novaLista.add(ingrediente);

    final receitaAtualizada = Receita(id: receita.id, nome: receita.nome, ingredientes: novaLista, percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento, imagemUrl: receita.imagemUrl);

    await atualizarReceita(receitaAtualizada);
  }

  Future<void> removerIngrediente(Receita receita, String ingredienteId) async {
    final novaLista = receita.ingredientes.where((ingrediente) => ingrediente.id != ingredienteId).toList();

    final receitaAtualizada = Receita(id: receita.id, nome: receita.nome, ingredientes: novaLista, percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento, imagemUrl: receita.imagemUrl);

    await atualizarReceita(receitaAtualizada);
  }

  Future<void> editarIngrediente(Receita receita, String ingredienteId, Produto produto, double quantidade, String unidade, {String? fracao}) async {
    final novaLista = List<Ingrediente>.from(receita.ingredientes);
    final index = novaLista.indexWhere((ingrediente) => ingrediente.id == ingredienteId);

    if (index != -1) {
      novaLista[index] = Ingrediente(id: ingredienteId, produto: produto, quantidade: quantidade, unidade: unidade, fracao: fracao);

      final receitaAtualizada = Receita(id: receita.id, nome: receita.nome, ingredientes: novaLista, percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento, imagemUrl: receita.imagemUrl);

      await atualizarReceita(receitaAtualizada);
    }
  }
}
