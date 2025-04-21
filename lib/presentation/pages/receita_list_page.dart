import 'dart:io';
import 'package:flutter/material.dart';
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
    // Carregar os produtos quando a tela for inicializada
    Future.microtask(() => context.read<ReceitaController>().carregarReceitas());
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
              ? _buildListaVazia()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.receitas.length,
                itemBuilder: (context, index) {
                  final receita = controller.receitas[index];
                  return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: const EdgeInsets.all(12), leading: _buildReceitaImagem(receita), title: Text(receita.nome, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('Rendimento: ${receita.rendimento} ${receita.unidadeRendimento}'), Text('Preço por ${receita.unidadeRendimento}: ${MoneyFormatter.formatReal(receita.valorPorUnidade)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editarReceita(receita)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarExclusao(receita))]), onTap: () => context.push('/receitas/detalhes/${receita.id}')));
                },
              ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/receitas/nova'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, child: const Icon(Icons.add)),
    );
  }

  Widget _buildListaVazia() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey), const SizedBox(height: 16), const Text('Nenhuma receita cadastrada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Adicione receitas para calcular os preços', style: TextStyle(color: Colors.grey)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => context.push('/receitas/nova'), icon: const Icon(Icons.add), label: const Text('Adicionar Receita'))]));
  }

  Widget _buildReceitaImagem(Receita receita) {
    if (receita.imagemUrl != null && receita.imagemUrl!.isNotEmpty) {
      try {
        return ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(width: 50, height: 50, child: receita.imagemUrl!.startsWith('http') ? Image.network(receita.imagemUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30)) : Image.file(File(receita.imagemUrl!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30))));
      } catch (e) {
        return const CircleAvatar(child: Icon(Icons.image_not_supported));
      }
    }
    return const CircleAvatar(child: Icon(Icons.restaurant_menu));
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
            content: Text('Deseja realmente excluir a receita "${receita.nome}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _excluirReceita(receita.id);
                },
                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _excluirReceita(String id) {
    try {
      context.read<ReceitaController>().removerReceita(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receita excluída com sucesso'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir receita: $e'), backgroundColor: Colors.red));
    }
  }
}
