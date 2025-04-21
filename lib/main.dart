import 'package:flutter/material.dart';
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
  final produtoController = ProdutoController(
    obterTodosProdutosUseCase: obterTodosProdutosUseCase,
    obterProdutoPorIdUseCase: obterProdutoPorIdUseCase,
    salvarProdutoUseCase: salvarProdutoUseCase,
    atualizarProdutoUseCase: atualizarProdutoUseCase,
    removerProdutoUseCase: removerProdutoUseCase,
    obterTodasReceitasUseCase: obterTodasReceitasUseCase,
    atualizarReceitaUseCase: atualizarReceitaUseCase,
  );

  final receitaController = ReceitaController(
    obterTodasReceitasUseCase: obterTodasReceitasUseCase,
    obterReceitaPorIdUseCase: obterReceitaPorIdUseCase,
    salvarReceitaUseCase: salvarReceitaUseCase,
    atualizarReceitaUseCase: atualizarReceitaUseCase,
    removerReceitaUseCase: removerReceitaUseCase,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProdutoController>(create: (_) => produtoController),
        ChangeNotifierProvider<ReceitaController>(create: (_) => receitaController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Meu Preço',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, primary: Colors.green, secondary: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        ),
      ),
      routerConfig: router,
    );
  }
}
