import 'package:flutter/material.dart';
import 'package:meu_preco/core/utils/id_generator.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/usecases/produto_usecases.dart';

class ProdutoController extends ChangeNotifier {
  ObterTodosProdutosUseCase _obterTodosProdutosUseCase;
  ObterProdutoPorIdUseCase _obterProdutoPorIdUseCase;
  SalvarProdutoUseCase _salvarProdutoUseCase;
  AtualizarProdutoUseCase _atualizarProdutoUseCase;
  RemoverProdutoUseCase _removerProdutoUseCase;

  ProdutoController({required ObterTodosProdutosUseCase obterTodosProdutosUseCase, required ObterProdutoPorIdUseCase obterProdutoPorIdUseCase, required SalvarProdutoUseCase salvarProdutoUseCase, required AtualizarProdutoUseCase atualizarProdutoUseCase, required RemoverProdutoUseCase removerProdutoUseCase}) : _obterTodosProdutosUseCase = obterTodosProdutosUseCase, _obterProdutoPorIdUseCase = obterProdutoPorIdUseCase, _salvarProdutoUseCase = salvarProdutoUseCase, _atualizarProdutoUseCase = atualizarProdutoUseCase, _removerProdutoUseCase = removerProdutoUseCase;

  // Setters para injeção de dependência
  set obterTodosProdutosUseCase(ObterTodosProdutosUseCase useCase) {
    _obterTodosProdutosUseCase = useCase;
  }

  set obterProdutoPorIdUseCase(ObterProdutoPorIdUseCase useCase) {
    _obterProdutoPorIdUseCase = useCase;
  }

  set salvarProdutoUseCase(SalvarProdutoUseCase useCase) {
    _salvarProdutoUseCase = useCase;
  }

  set atualizarProdutoUseCase(AtualizarProdutoUseCase useCase) {
    _atualizarProdutoUseCase = useCase;
  }

  set removerProdutoUseCase(RemoverProdutoUseCase useCase) {
    _removerProdutoUseCase = useCase;
  }

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregarProdutos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _produtos = await _obterTodosProdutosUseCase.executar();
    } catch (e) {
      _erro = 'Erro ao carregar produtos: ${e.toString()}';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> salvarProduto({required String nome, required double preco, required double quantidade, required String unidade}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final produto = Produto(id: IdGenerator.generate(), nome: nome, preco: preco, quantidade: quantidade, unidade: unidade);

      await _salvarProdutoUseCase.executar(produto);
      await carregarProdutos();
    } catch (e) {
      _erro = 'Erro ao salvar produto: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> atualizarProduto(Produto produto) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _atualizarProdutoUseCase.executar(produto);
      await carregarProdutos();
    } catch (e) {
      _erro = 'Erro ao atualizar produto: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> removerProduto(String id) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _removerProdutoUseCase.executar(id);
      await carregarProdutos();
    } catch (e) {
      _erro = 'Erro ao remover produto: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Produto?> obterProdutoPorId(String id) async {
    try {
      return await _obterProdutoPorIdUseCase.executar(id);
    } catch (e) {
      _erro = 'Erro ao obter produto: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
