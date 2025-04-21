import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/presentation/controllers/receita_controller.dart';
import 'package:provider/provider.dart';

class ReceitaListPage extends StatefulWidget {
  const ReceitaListPage({super.key});

  @override
  State<ReceitaListPage> createState() => _ReceitaListPageState();
}

class _ReceitaListPageState extends State<ReceitaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceitaController>().carregarReceitas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReceitaController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
      body:
          controller.carregando
              ? const Center(child: CircularProgressIndicator())
              : controller.erro != null
              ? Center(child: Text(controller.erro!))
              : controller.receitas.isEmpty
              ? const Center(child: Text('Nenhuma receita cadastrada.'))
              : ListView.builder(
                itemCount: controller.receitas.length,
                itemBuilder: (context, index) {
                  final receita = controller.receitas[index];
                  return Slidable(endActionPane: ActionPane(motion: const ScrollMotion(), children: [SlidableAction(onPressed: (_) => _editarReceita(receita), backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: 'Editar'), SlidableAction(onPressed: (_) => _confirmarExclusao(receita), backgroundColor: Colors.red, foregroundColor: Colors.white, icon: Icons.delete, label: 'Excluir')]), child: ListTile(title: Text(receita.nome), subtitle: Text('Valor: ${MoneyFormatter.formatReal(receita.valorTotal)} | Rende: ${receita.rendimento} ${receita.unidadeRendimento}'), trailing: Text('Unitário: ${MoneyFormatter.formatReal(receita.valorPorUnidade)}', style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => context.push('/receitas/detalhes/${receita.id}')));
                },
              ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/receitas/cadastrar'), child: const Icon(Icons.add)),
    );
  }

  void _editarReceita(Receita receita) {
    context.push('/receitas/editar/${receita.id}');
  }

  void _confirmarExclusao(Receita receita) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text('Deseja realmente excluir a receita ${receita.nome}?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  context.read<ReceitaController>().removerReceita(receita.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }
}
