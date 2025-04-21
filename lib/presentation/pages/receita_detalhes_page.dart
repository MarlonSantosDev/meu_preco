import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/presentation/controllers/receita_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReceitaDetalhesPage extends StatefulWidget {
  final String receitaId;

  const ReceitaDetalhesPage({super.key, required this.receitaId});

  @override
  State<ReceitaDetalhesPage> createState() => _ReceitaDetalhesPageState();
}

class _ReceitaDetalhesPageState extends State<ReceitaDetalhesPage> {
  bool _carregando = true;
  String? _erro;
  Receita? _receita;

  @override
  void initState() {
    super.initState();
    _carregarReceita();
  }

  Future<void> _carregarReceita() async {
    try {
      final controller = context.read<ReceitaController>();
      final receita = await controller.obterReceitaPorId(widget.receitaId);

      if (receita != null) {
        setState(() {
          _receita = receita;
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Receita não encontrada';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar receita: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_receita?.nome ?? 'Detalhes da Receita'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_receita != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/receitas/editar/${_receita!.id}')),
        ],
      ),
      body:
          _carregando
              ? const Center(child: CircularProgressIndicator())
              : _erro != null
              ? Center(child: Text(_erro!))
              : _receita == null
              ? const Center(child: Text('Receita não encontrada'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_receita!.nome, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text(
                              'Rendimento: ${_receita!.rendimento} ${_receita!.unidadeRendimento}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.update, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(_receita!.dataUltimaAtualizacao)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _receita!.ingredientes.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final ingrediente = _receita!.ingredientes[index];
                            return ListTile(
                              title: Text(ingrediente.produto.nome),
                              subtitle: Text('${ingrediente.quantidade} ${ingrediente.unidade}'),
                              trailing: Text(MoneyFormatter.formatReal(ingrediente.custoTotal)),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Precificação',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildCardPrecificacao(),
                  ],
                ),
              ),
    );
  }

  Widget _buildCardPrecificacao() {
    if (_receita == null) return const SizedBox.shrink();

    final custoIngredientes = _receita!.custoIngredientes;
    final valorGastosEscondidos = _receita!.valorGastosEscondidos;
    final valorMaoDeObra = _receita!.valorMaoDeObra;
    final valorLucro = _receita!.valorLucro;
    final valorTotal = _receita!.valorTotal;
    final valorPorUnidade = _receita!.valorPorUnidade;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemPrecificacao('Custo dos Ingredientes', MoneyFormatter.formatReal(custoIngredientes)),
            const Divider(),
            _buildItemPrecificacao(
              'Gastos "escondidos" (${NumberFormatter.formatPercent(_receita!.percentualGastos)})',
              MoneyFormatter.formatReal(valorGastosEscondidos),
            ),
            const Divider(),
            _buildItemPrecificacao(
              'Mão de obra (${NumberFormatter.formatPercent(_receita!.percentualMaoDeObra)})',
              MoneyFormatter.formatReal(valorMaoDeObra),
            ),
            const Divider(),
            _buildItemPrecificacao(
              'Total percentuais (${NumberFormatter.formatPercent(_receita!.percentualTotal)})',
              MoneyFormatter.formatReal(_receita!.valorPercentuais),
            ),
            const Divider(),
            _buildItemPrecificacao('Lucro (100%)', MoneyFormatter.formatReal(valorLucro)),
            const Divider(),
            _buildItemPrecificacao('Valor Total', MoneyFormatter.formatReal(valorTotal), destaque: true),
            const Divider(),
            _buildItemPrecificacao(
              'Valor por ${_receita!.unidadeRendimento}',
              MoneyFormatter.formatReal(valorPorUnidade),
              destaque: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPrecificacao(String label, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal, fontSize: destaque ? 16 : 14),
          ),
          Text(
            valor,
            style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal, fontSize: destaque ? 16 : 14),
          ),
        ],
      ),
    );
  }
}
