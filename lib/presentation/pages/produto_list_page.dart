import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProdutoController>().carregarProdutos();
    });
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
              ? const Center(child: Text('Nenhum produto cadastrado.'))
              : ListView.builder(
                itemCount: controller.produtos.length,
                itemBuilder: (context, index) {
                  final produto = controller.produtos[index];
                  return Slidable(endActionPane: ActionPane(motion: const ScrollMotion(), children: [SlidableAction(onPressed: (_) => _editarProduto(produto), backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: 'Editar'), SlidableAction(onPressed: (_) => _confirmarExclusao(produto), backgroundColor: Colors.red, foregroundColor: Colors.white, icon: Icons.delete, label: 'Excluir')]), child: ListTile(leading: _buildProdutoImagem(produto), title: Text(produto.nome), subtitle: Text('${produto.quantidade} ${produto.unidade} - ${MoneyFormatter.formatReal(produto.preco)}'), onTap: () => _editarProduto(produto)));
                },
              ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/produtos/cadastrar'), child: const Icon(Icons.add)),
    );
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
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  void _excluirProduto(String id) {
    context.read<ProdutoController>().removerProduto(id);
  }
}
