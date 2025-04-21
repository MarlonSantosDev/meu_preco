import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Preço'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Image.asset('assets/images/imagem_home.png', height: 120),
            const SizedBox(height: 48),
            Text(
              'Calcule o preço dos seus produtos',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cadastre seus insumos, crie receitas e precifique seus produtos de forma rápida e precisa.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.push('/produtos'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Gerenciar Produtos'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/receitas'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Gerenciar Receitas'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/sobre'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sobre'),
            ),
          ],
        ),
      ),
    );
  }
}
