import 'package:flutter/material.dart';
import 'package:meu_preco/core/utils/id_generator.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/usecases/produto_usecases.dart';
import 'package:meu_preco/domain/usecases/receita_usecases.dart';

class ProdutoController extends ChangeNotifier {
  ObterTodosProdutosUseCase _obterTodosProdutosUseCase;
  ObterProdutoPorIdUseCase _obterProdutoPorIdUseCase;
  SalvarProdutoUseCase _salvarProdutoUseCase;
  AtualizarProdutoUseCase _atualizarProdutoUseCase;
  RemoverProdutoUseCase _removerProdutoUseCase;

  // Adicionando casos de uso de receitas para atualização automática
  ObterTodasReceitasUseCase? _obterTodasReceitasUseCase;
  AtualizarReceitaUseCase? _atualizarReceitaUseCase;

  ProdutoController({required ObterTodosProdutosUseCase obterTodosProdutosUseCase, required ObterProdutoPorIdUseCase obterProdutoPorIdUseCase, required SalvarProdutoUseCase salvarProdutoUseCase, required AtualizarProdutoUseCase atualizarProdutoUseCase, required RemoverProdutoUseCase removerProdutoUseCase, ObterTodasReceitasUseCase? obterTodasReceitasUseCase, AtualizarReceitaUseCase? atualizarReceitaUseCase}) : _obterTodosProdutosUseCase = obterTodosProdutosUseCase, _obterProdutoPorIdUseCase = obterProdutoPorIdUseCase, _salvarProdutoUseCase = salvarProdutoUseCase, _atualizarProdutoUseCase = atualizarProdutoUseCase, _removerProdutoUseCase = removerProdutoUseCase, _obterTodasReceitasUseCase = obterTodasReceitasUseCase, _atualizarReceitaUseCase = atualizarReceitaUseCase;

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

  // Setters para casos de uso de receitas
  set obterTodasReceitasUseCase(ObterTodasReceitasUseCase useCase) {
    _obterTodasReceitasUseCase = useCase;
  }

  set atualizarReceitaUseCase(AtualizarReceitaUseCase useCase) {
    _atualizarReceitaUseCase = useCase;
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

  Future<void> salvarProduto({required String nome, required double preco, required double quantidade, required String unidade, String? imagemUrl}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final produto = Produto(id: IdGenerator.generate(), nome: nome, preco: preco, quantidade: quantidade, unidade: unidade, imagemUrl: imagemUrl);

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

      // Atualizar receitas que usam este produto
      await _atualizarReceitasComProduto(produto);

      await carregarProdutos();
    } catch (e) {
      _erro = 'Erro ao atualizar produto: ${e.toString()}';
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> _atualizarReceitasComProduto(Produto produto) async {
    // Verifica se as dependências para atualização de receitas estão disponíveis
    if (_obterTodasReceitasUseCase == null || _atualizarReceitaUseCase == null) {
      return;
    }

    try {
      // Obter todas as receitas
      final receitas = await _obterTodasReceitasUseCase!.executar();

      // Percorrer todas as receitas para encontrar as que usam o produto atualizado
      for (var receita in receitas) {
        bool receitaModificada = false;

        // Verificar se algum ingrediente usa o produto
        for (var i = 0; i < receita.ingredientes.length; i++) {
          final ingrediente = receita.ingredientes[i];

          // Se o ingrediente usa o produto atualizado
          if (ingrediente.produto.id == produto.id) {
            receitaModificada = true;
            // Não é necessário modificar o ingrediente, pois a atualização do produto
            // já irá refletir no cálculo do preço automaticamente
          }
        }

        // Se a receita foi modificada, atualizá-la no repositório
        if (receitaModificada) {
          // Criar uma nova receita com a data de atualização atual
          final receitaAtualizada = Receita(id: receita.id, nome: receita.nome, ingredientes: receita.ingredientes, percentualGastos: receita.percentualGastos, percentualMaoDeObra: receita.percentualMaoDeObra, rendimento: receita.rendimento, unidadeRendimento: receita.unidadeRendimento, imagemUrl: receita.imagemUrl, dataUltimaAtualizacao: DateTime.now());

          await _atualizarReceitaUseCase!.executar(receitaAtualizada);
        }
      }
    } catch (e) {
      _erro = 'Erro ao atualizar receitas: ${e.toString()}';
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
