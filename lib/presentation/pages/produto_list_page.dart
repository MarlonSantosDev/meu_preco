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
                  return Slidable(endActionPane: ActionPane(motion: const ScrollMotion(), children: [SlidableAction(onPressed: (_) => _editarProduto(produto), backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: 'Editar'), SlidableAction(onPressed: (_) => _confirmarExclusao(produto), backgroundColor: Colors.red, foregroundColor: Colors.white, icon: Icons.delete, label: 'Excluir')]), child: ListTile(title: Text(produto.nome), subtitle: Text('${produto.quantidade} ${produto.unidade} - ${MoneyFormatter.formatReal(produto.preco)}'), onTap: () => _editarProduto(produto)));
                },
              ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/produtos/cadastrar'), child: const Icon(Icons.add)),
    );
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
            content: Text('Deseja realmente excluir o produto ${produto.nome}?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  context.read<ProdutoController>().removerProduto(produto.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }
}
