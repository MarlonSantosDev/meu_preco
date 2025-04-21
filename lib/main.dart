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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Datasource
        Provider(create: (_) => HiveDataSource()),

        // Repositories
        ProxyProvider<HiveDataSource, ProdutoRepositoryImpl>(update: (_, dataSource, __) => ProdutoRepositoryImpl(dataSource)),
        ProxyProvider<HiveDataSource, ReceitaRepositoryImpl>(update: (_, dataSource, __) => ReceitaRepositoryImpl(dataSource)),

        // Usecases - Produtos
        ProxyProvider<ProdutoRepositoryImpl, ObterTodosProdutosUseCase>(update: (_, repository, __) => ObterTodosProdutosUseCase(repository)),
        ProxyProvider<ProdutoRepositoryImpl, ObterProdutoPorIdUseCase>(update: (_, repository, __) => ObterProdutoPorIdUseCase(repository)),
        ProxyProvider<ProdutoRepositoryImpl, SalvarProdutoUseCase>(update: (_, repository, __) => SalvarProdutoUseCase(repository)),
        ProxyProvider<ProdutoRepositoryImpl, AtualizarProdutoUseCase>(update: (_, repository, __) => AtualizarProdutoUseCase(repository)),
        ProxyProvider<ProdutoRepositoryImpl, RemoverProdutoUseCase>(update: (_, repository, __) => RemoverProdutoUseCase(repository)),

        // Usecases - Receitas
        ProxyProvider<ReceitaRepositoryImpl, ObterTodasReceitasUseCase>(update: (_, repository, __) => ObterTodasReceitasUseCase(repository)),
        ProxyProvider<ReceitaRepositoryImpl, ObterReceitaPorIdUseCase>(update: (_, repository, __) => ObterReceitaPorIdUseCase(repository)),
        ProxyProvider<ReceitaRepositoryImpl, SalvarReceitaUseCase>(update: (_, repository, __) => SalvarReceitaUseCase(repository)),
        ProxyProvider<ReceitaRepositoryImpl, AtualizarReceitaUseCase>(update: (_, repository, __) => AtualizarReceitaUseCase(repository)),
        ProxyProvider<ReceitaRepositoryImpl, RemoverReceitaUseCase>(update: (_, repository, __) => RemoverReceitaUseCase(repository)),

        // Controllers
        ChangeNotifierProxyProvider5<ObterTodosProdutosUseCase, ObterProdutoPorIdUseCase, SalvarProdutoUseCase, AtualizarProdutoUseCase, RemoverProdutoUseCase, ProdutoController>(
          create: (_) => ProdutoController(obterTodosProdutosUseCase: ObterTodosProdutosUseCase(ProdutoRepositoryImpl(HiveDataSource())), obterProdutoPorIdUseCase: ObterProdutoPorIdUseCase(ProdutoRepositoryImpl(HiveDataSource())), salvarProdutoUseCase: SalvarProdutoUseCase(ProdutoRepositoryImpl(HiveDataSource())), atualizarProdutoUseCase: AtualizarProdutoUseCase(ProdutoRepositoryImpl(HiveDataSource())), removerProdutoUseCase: RemoverProdutoUseCase(ProdutoRepositoryImpl(HiveDataSource())), obterTodasReceitasUseCase: ObterTodasReceitasUseCase(ReceitaRepositoryImpl(HiveDataSource())), atualizarReceitaUseCase: AtualizarReceitaUseCase(ReceitaRepositoryImpl(HiveDataSource()))),
          update: (_, obterTodos, obterPorId, salvar, atualizar, remover, previous) {
            previous!
              ..obterTodosProdutosUseCase = obterTodos
              ..obterProdutoPorIdUseCase = obterPorId
              ..salvarProdutoUseCase = salvar
              ..atualizarProdutoUseCase = atualizar
              ..removerProdutoUseCase = remover;
            return previous;
          },
        ),

        // Injetando dependências de receitas no ProdutoController
        ProxyProvider2<ObterTodasReceitasUseCase, AtualizarReceitaUseCase, ProdutoController>(
          update: (_, obterTodasReceitas, atualizarReceita, previous) {
            if (previous != null) {
              previous
                ..obterTodasReceitasUseCase = obterTodasReceitas
                ..atualizarReceitaUseCase = atualizarReceita;
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider5<ObterTodasReceitasUseCase, ObterReceitaPorIdUseCase, SalvarReceitaUseCase, AtualizarReceitaUseCase, RemoverReceitaUseCase, ReceitaController>(
          create: (_) => ReceitaController(obterTodasReceitasUseCase: ObterTodasReceitasUseCase(ReceitaRepositoryImpl(HiveDataSource())), obterReceitaPorIdUseCase: ObterReceitaPorIdUseCase(ReceitaRepositoryImpl(HiveDataSource())), salvarReceitaUseCase: SalvarReceitaUseCase(ReceitaRepositoryImpl(HiveDataSource())), atualizarReceitaUseCase: AtualizarReceitaUseCase(ReceitaRepositoryImpl(HiveDataSource())), removerReceitaUseCase: RemoverReceitaUseCase(ReceitaRepositoryImpl(HiveDataSource()))),
          update: (_, obterTodas, obterPorId, salvar, atualizar, remover, previous) {
            previous!
              ..obterTodasReceitasUseCase = obterTodas
              ..obterReceitaPorIdUseCase = obterPorId
              ..salvarReceitaUseCase = salvar
              ..atualizarReceitaUseCase = atualizar
              ..removerReceitaUseCase = remover;
            return previous;
          },
        ),
      ],
      child: MaterialApp.router(title: 'Meu Preço', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, primary: Colors.green, secondary: Colors.teal), useMaterial3: true, appBarTheme: const AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white), elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))), routerConfig: router),
    );
  }
}
