import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:provider/provider.dart';

class ProdutoFormPage extends StatefulWidget {
  final String? produtoId;

  const ProdutoFormPage({super.key, this.produtoId});

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();

  bool _isEdicao = false;
  bool _carregando = true;
  String? _erro;

  String _unidade = 'kg'; // Valor padrão
  final List<String> _unidades = ['kg', 'g', 'L', 'ml', 'unidade'];

  Produto? _produtoOriginal;

  @override
  void initState() {
    super.initState();
    _carregarProduto();
  }

  Future<void> _carregarProduto() async {
    if (widget.produtoId != null) {
      _isEdicao = true;
      try {
        final controller = context.read<ProdutoController>();
        final produto = await controller.obterProdutoPorId(widget.produtoId!);

        if (produto != null) {
          setState(() {
            _produtoOriginal = produto;
            _nomeController.text = produto.nome;
            _precoController.text = produto.preco.toString();
            _quantidadeController.text = produto.quantidade.toString();
            _unidade = produto.unidade;
            _carregando = false;
          });
        } else {
          setState(() {
            _erro = 'Produto não encontrado';
            _carregando = false;
          });
        }
      } catch (e) {
        setState(() {
          _erro = 'Erro ao carregar produto: $e';
          _carregando = false;
        });
      }
    } else {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdicao ? 'Editar Produto' : 'Cadastrar Produto'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
      body:
          _carregando
              ? const Center(child: CircularProgressIndicator())
              : _erro != null
              ? Center(child: Text(_erro!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome do Produto', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome do produto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantidadeController,
                              decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite a quantidade';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Digite um número válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _unidade,
                              decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                              items:
                                  _unidades.map((unidade) {
                                    return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _unidade = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precoController,
                        decoration: const InputDecoration(labelText: 'Preço (R\$)', border: OutlineInputBorder(), prefixText: 'R\$ '),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o preço';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Digite um preço válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _salvar, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_isEdicao ? 'Atualizar' : 'Cadastrar')),
                    ],
                  ),
                ),
              ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<ProdutoController>();

      final nome = _nomeController.text;
      final preco = double.parse(_precoController.text);
      final quantidade = double.parse(_quantidadeController.text);

      if (_isEdicao && _produtoOriginal != null) {
        final produtoAtualizado = Produto(id: _produtoOriginal!.id, nome: nome, preco: preco, quantidade: quantidade, unidade: _unidade);

        controller.atualizarProduto(produtoAtualizado);
      } else {
        controller.salvarProduto(nome: nome, preco: preco, quantidade: quantidade, unidade: _unidade);
      }

      context.pop();
    }
  }
}
