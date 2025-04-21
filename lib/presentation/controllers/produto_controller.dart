import 'package:flutter/material.dart';
import 'package:meu_preco/core/utils/id_generator.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';
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

  ProdutoController({
    required ObterTodosProdutosUseCase obterTodosProdutosUseCase,
    required ObterProdutoPorIdUseCase obterProdutoPorIdUseCase,
    required SalvarProdutoUseCase salvarProdutoUseCase,
    required AtualizarProdutoUseCase atualizarProdutoUseCase,
    required RemoverProdutoUseCase removerProdutoUseCase,
    ObterTodasReceitasUseCase? obterTodasReceitasUseCase,
    AtualizarReceitaUseCase? atualizarReceitaUseCase,
  }) : _obterTodosProdutosUseCase = obterTodosProdutosUseCase,
       _obterProdutoPorIdUseCase = obterProdutoPorIdUseCase,
       _salvarProdutoUseCase = salvarProdutoUseCase,
       _atualizarProdutoUseCase = atualizarProdutoUseCase,
       _removerProdutoUseCase = removerProdutoUseCase,
       _obterTodasReceitasUseCase = obterTodasReceitasUseCase,
       _atualizarReceitaUseCase = atualizarReceitaUseCase;

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

  Future<void> salvarProduto({
    required String nome,
    required double preco,
    required double quantidade,
    required String unidade,
    String? imagemUrl,
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      // Verificar se já existe um produto com o mesmo nome
      if (existeProdutoComNome(nome)) {
        throw Exception('Já existe um produto com este nome. Por favor, escolha outro nome.');
      }

      final produto = Produto(
        id: IdGenerator.generate(),
        nome: nome,
        preco: preco,
        quantidade: quantidade,
        unidade: unidade,
        imagemUrl: imagemUrl,
      );

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
      // Verificar se já existe um produto com o mesmo nome (exceto o próprio produto)
      if (existeProdutoComNome(produto.nome, idIgnorar: produto.id)) {
        throw Exception('Já existe um produto com este nome. Por favor, escolha outro nome.');
      }

      // Primeiro, atualize o produto no repositório
      await _atualizarProdutoUseCase.executar(produto);

      // Depois, atualize as receitas que usam este produto
      await _atualizarReceitasComProduto(produto);

      // Por fim, recarregue os produtos
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
      debugPrint('Dependências de receitas não disponíveis para atualização automática');
      return;
    }

    try {
      // Obter todas as receitas
      final receitas = await _obterTodasReceitasUseCase!.executar();
      int receitasAtualizadas = 0;

      // Percorrer todas as receitas para encontrar as que usam o produto atualizado
      for (var receita in receitas) {
        bool receitaModificada = false;
        List<Ingrediente> ingredientesAtualizados = [];

        // Verificar se algum ingrediente usa o produto
        for (var ingrediente in receita.ingredientes) {
          // Se o ingrediente usa o produto atualizado
          if (ingrediente.produto.id == produto.id) {
            receitaModificada = true;
            // Criar um novo ingrediente com o produto atualizado
            ingredientesAtualizados.add(
              Ingrediente(
                id: ingrediente.id,
                produto: produto, // Usar o produto atualizado
                quantidade: ingrediente.quantidade,
                unidade: ingrediente.unidade,
                fracao: ingrediente.fracao,
              ),
            );
          } else {
            // Manter o ingrediente original
            ingredientesAtualizados.add(ingrediente);
          }
        }

        // Se a receita foi modificada, atualizá-la no repositório
        if (receitaModificada) {
          receitasAtualizadas++;
          debugPrint('Atualizando receita: ${receita.nome} com produto atualizado: ${produto.nome}');

          // Criar uma nova receita com a data de atualização atual e ingredientes atualizados
          final receitaAtualizada = Receita(
            id: receita.id,
            nome: receita.nome,
            ingredientes: ingredientesAtualizados, // Usar a lista de ingredientes atualizada
            percentualGastos: receita.percentualGastos,
            percentualMaoDeObra: receita.percentualMaoDeObra,
            rendimento: receita.rendimento,
            unidadeRendimento: receita.unidadeRendimento,
            imagemUrl: receita.imagemUrl,
            dataUltimaAtualizacao: DateTime.now(),
          );

          await _atualizarReceitaUseCase!.executar(receitaAtualizada);
        }
      }

      debugPrint('Atualizadas $receitasAtualizadas receitas que contêm o produto ${produto.nome}');
    } catch (e) {
      _erro = 'Erro ao atualizar receitas: ${e.toString()}';
      debugPrint('Erro ao atualizar receitas com produto ${produto.nome}: ${e.toString()}');
      notifyListeners();
    }
  }

  Future<void> removerProduto(String id) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      // Verificar se o produto está sendo usado em alguma receita
      if (_obterTodasReceitasUseCase != null) {
        debugPrint('Verificando se o produto $id está sendo usado em receitas...');
        final receitas = await _obterTodasReceitasUseCase!.executar();
        debugPrint('Encontradas ${receitas.length} receitas para verificar');

        // Procurar o produto em todas as receitas
        for (final receita in receitas) {
          for (final ingrediente in receita.ingredientes) {
            if (ingrediente.produto.id == id) {
              debugPrint('Produto $id encontrado na receita "${receita.nome}" - impedindo exclusão');
              throw Exception(
                'Não é possível excluir este produto pois ele está sendo usado na receita "${receita.nome}". Remova o produto da receita primeiro ou use outro produto.',
              );
            }
          }
        }
        debugPrint('Produto $id não está sendo usado em nenhuma receita, pode ser excluído');
      } else {
        debugPrint('ObterTodasReceitasUseCase é nulo, não é possível verificar o uso do produto em receitas');
      }

      // Se o produto não está sendo usado em nenhuma receita, pode ser removido
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

  // Método para verificar se já existe produto com o mesmo nome
  bool existeProdutoComNome(String nome, {String? idIgnorar}) {
    return _produtos.any(
      (produto) => produto.nome.toLowerCase() == nome.toLowerCase() && (idIgnorar == null || produto.id != idIgnorar),
    );
  }
}
