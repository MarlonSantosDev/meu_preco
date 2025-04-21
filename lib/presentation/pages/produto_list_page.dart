import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:provider/provider.dart';

class ProdutoListPage extends StatefulWidget {
  const ProdutoListPage({super.key});

  @override
  State<ProdutoListPage> createState() => _ProdutoListPageState();
}

class _ProdutoListPageState extends State<ProdutoListPage> {
  @override
  void initState() {
    super.initState();
    // Carregar os produtos quando a tela for inicializada
    Future.microtask(() => context.read<ProdutoController>().carregarProdutos());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProdutoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Produtos'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
      body:
          controller.carregando
              ? const Center(child: CircularProgressIndicator())
              : controller.erro != null
              ? Center(child: Text(controller.erro!))
              : controller.produtos.isEmpty
              ? _buildListaVazia()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.produtos.length,
                itemBuilder: (context, index) {
                  final produto = controller.produtos[index];
                  return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: const EdgeInsets.all(12), leading: _buildProdutoImagem(produto), title: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('${produto.quantidade} ${produto.unidade}'), Text(MoneyFormatter.formatReal(produto.preco), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editarProduto(produto)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarExclusao(produto))]), onTap: () => _editarProduto(produto)));
                },
              ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/produtos/novo'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, child: const Icon(Icons.add)),
    );
  }

  Widget _buildListaVazia() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.shopping_basket, size: 80, color: Colors.grey), const SizedBox(height: 16), const Text('Nenhum produto cadastrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Adicione produtos para criar suas receitas', style: TextStyle(color: Colors.grey)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => context.push('/produtos/novo'), icon: const Icon(Icons.add), label: const Text('Adicionar Produto'))]));
  }

  Widget _buildProdutoImagem(Produto produto) {
    if (produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty) {
      try {
        return ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(width: 50, height: 50, child: produto.imagemUrl!.startsWith('http') ? Image.network(produto.imagemUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30)) : Image.file(File(produto.imagemUrl!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30))));
      } catch (e) {
        return const CircleAvatar(child: Icon(Icons.image_not_supported));
      }
    }
    return const CircleAvatar(child: Icon(Icons.image));
  }

  void _editarProduto(Produto produto) {
    context.push('/produtos/editar/${produto.id}');
  }

  void _confirmarExclusao(Produto produto) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text('Deseja realmente excluir o produto "${produto.nome}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _excluirProduto(produto.id);
                },
                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _excluirProduto(String id) {
    try {
      context.read<ProdutoController>().removerProduto(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto excluído com sucesso'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir produto: $e'), backgroundColor: Colors.red));
    }
  }
}
