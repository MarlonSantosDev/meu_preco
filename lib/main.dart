import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_preco/data/datasources/hive_datasource.dart';
import 'package:meu_preco/data/repositories/produto_repository_impl.dart';
import 'package:meu_preco/data/repositories/receita_repository_impl.dart';
import 'package:meu_preco/domain/usecases/produto_usecases.dart';
import 'package:meu_preco/domain/usecases/receita_usecases.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:meu_preco/presentation/controllers/receita_controller.dart';
import 'package:meu_preco/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o Hive
  await HiveDataSource.init();

  // Teste de cálculo de precificação com base no modelo
  _testeCalculoPreco();

  // Criando datasource e repositories
  final dataSource = HiveDataSource();
  final produtoRepository = ProdutoRepositoryImpl(dataSource);
  final receitaRepository = ReceitaRepositoryImpl(dataSource);

  // Criando usecases de produto
  final obterTodosProdutosUseCase = ObterTodosProdutosUseCase(produtoRepository);
  final obterProdutoPorIdUseCase = ObterProdutoPorIdUseCase(produtoRepository);
  final salvarProdutoUseCase = SalvarProdutoUseCase(produtoRepository);
  final atualizarProdutoUseCase = AtualizarProdutoUseCase(produtoRepository);
  final removerProdutoUseCase = RemoverProdutoUseCase(produtoRepository);

  // Criando usecases de receita
  final obterTodasReceitasUseCase = ObterTodasReceitasUseCase(receitaRepository);
  final obterReceitaPorIdUseCase = ObterReceitaPorIdUseCase(receitaRepository);
  final salvarReceitaUseCase = SalvarReceitaUseCase(receitaRepository);
  final atualizarReceitaUseCase = AtualizarReceitaUseCase(receitaRepository);
  final removerReceitaUseCase = RemoverReceitaUseCase(receitaRepository);

  // Criando controllers
  final produtoController = ProdutoController(obterTodosProdutosUseCase: obterTodosProdutosUseCase, obterProdutoPorIdUseCase: obterProdutoPorIdUseCase, salvarProdutoUseCase: salvarProdutoUseCase, atualizarProdutoUseCase: atualizarProdutoUseCase, removerProdutoUseCase: removerProdutoUseCase, obterTodasReceitasUseCase: obterTodasReceitasUseCase, atualizarReceitaUseCase: atualizarReceitaUseCase);

  final receitaController = ReceitaController(obterTodasReceitasUseCase: obterTodasReceitasUseCase, obterReceitaPorIdUseCase: obterReceitaPorIdUseCase, salvarReceitaUseCase: salvarReceitaUseCase, atualizarReceitaUseCase: atualizarReceitaUseCase, removerReceitaUseCase: removerReceitaUseCase);

  runApp(MultiProvider(providers: [ChangeNotifierProvider<ProdutoController>(create: (_) => produtoController), ChangeNotifierProvider<ReceitaController>(create: (_) => receitaController)], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Meu Preço', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, primary: Colors.green, secondary: Colors.teal), useMaterial3: true, appBarTheme: const AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white), elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))), routerConfig: router);
  }
}

// Função para testar o cálculo de precificação
void _testeCalculoPreco() {
  print('\n=== TESTE DE CÁLCULO DO PREÇO ===');

  // Simulando o valor da receita como 10.93 (exemplo da imagem)
  double valorReceita = 10.93;
  double percentualGastos = 0.2; // 20%
  double percentualMaoDeObra = 0.2; // 20%

  // Calculando conforme o modelo
  double valorGastos = valorReceita * percentualGastos;
  double valorMaoDeObra = valorReceita * percentualMaoDeObra;
  double percentualTotal = percentualGastos + percentualMaoDeObra; // 40%
  double valorPercentuais = valorReceita * percentualTotal;
  double valorLucro = valorReceita; // 100% do valor da receita
  double valorTotal = valorReceita + valorPercentuais + valorLucro;

  print('Valor da Receita: $valorReceita');
  print('% Gastos: ${percentualGastos * 100}%');
  print('% Mão de Obra: ${percentualMaoDeObra * 100}%');
  print('Valor Gastos: $valorGastos');
  print('Valor Mão de Obra: $valorMaoDeObra');
  print('Valor Percentuais: $valorPercentuais');
  print('Valor Lucro (100%): $valorLucro');
  print('Valor Total: $valorTotal');

  // Verificando se o resultado é próximo do exemplo (26.23)
  print('Verificação: Valor esperado na imagem = 26.23, Valor calculado = $valorTotal');
  print('==================================\n');
}
