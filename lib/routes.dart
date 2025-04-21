import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_preco/presentation/pages/home_page.dart';
import 'package:meu_preco/presentation/pages/produto_form_page.dart';
import 'package:meu_preco/presentation/pages/produto_list_page.dart';
import 'package:meu_preco/presentation/pages/receita_detalhes_page.dart';
import 'package:meu_preco/presentation/pages/receita_form_page.dart';
import 'package:meu_preco/presentation/pages/receita_list_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/produtos',
      builder: (BuildContext context, GoRouterState state) {
        return const ProdutoListPage();
      },
    ),
    GoRoute(
      path: '/produtos/cadastrar',
      builder: (BuildContext context, GoRouterState state) {
        return const ProdutoFormPage();
      },
    ),
    GoRoute(
      path: '/produtos/editar/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id'];
        return ProdutoFormPage(produtoId: id);
      },
    ),
    GoRoute(
      path: '/receitas',
      builder: (BuildContext context, GoRouterState state) {
        return const ReceitaListPage();
      },
    ),
    GoRoute(
      path: '/receitas/cadastrar',
      builder: (BuildContext context, GoRouterState state) {
        return const ReceitaFormPage();
      },
    ),
    GoRoute(
      path: '/receitas/editar/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id'];
        return ReceitaFormPage(receitaId: id);
      },
    ),
    GoRoute(
      path: '/receitas/detalhes/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id']!;
        return ReceitaDetalhesPage(receitaId: id);
      },
    ),
  ],
);
