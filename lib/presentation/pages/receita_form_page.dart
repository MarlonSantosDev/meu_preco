import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:meu_preco/presentation/controllers/receita_controller.dart';
import 'package:provider/provider.dart';

class ReceitaFormPage extends StatefulWidget {
  final String? receitaId;

  const ReceitaFormPage({super.key, this.receitaId});

  @override
  State<ReceitaFormPage> createState() => _ReceitaFormPageState();
}

class _ReceitaFormPageState extends State<ReceitaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _rendimentoController = TextEditingController();

  String _unidadeRendimento = 'unidade';
  final List<String> _unidadesRendimento = ['unidade', 'kg', 'g', 'L', 'ml'];

  double _percentualGastos = 0.2; // 20% padrão
  double _percentualMaoDeObra = 0.2; // 20% padrão

  bool _isEdicao = false;
  bool _carregando = true;
  String? _erro;
  String? _imagemUrl;

  Receita? _receitaOriginal;
  List<Ingrediente> _ingredientes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // Carrega a lista de produtos
    try {
      // Use microtask para adiar a execução para após a conclusão do build atual
      Future.microtask(() async {
        await context.read<ProdutoController>().carregarProdutos();
        // Se for edição, carrega a receita
        if (widget.receitaId != null) {
          _isEdicao = true;
          try {
            final controller = context.read<ReceitaController>();
            final receita = await controller.obterReceitaPorId(widget.receitaId!);

            if (receita != null) {
              setState(() {
                _receitaOriginal = receita;
                _nomeController.text = receita.nome;
                _rendimentoController.text = receita.rendimento.toString();
                _unidadeRendimento = receita.unidadeRendimento;
                _percentualGastos = receita.percentualGastos;
                _percentualMaoDeObra = receita.percentualMaoDeObra;
                _ingredientes = List.from(receita.ingredientes);
                _imagemUrl = receita.imagemUrl;
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
        } else {
          setState(() {
            _carregando = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar produtos: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Copiar a imagem para um local permanente
      final documentsDir = await getApplicationDocumentsDirectory();
      final filename = 'receita_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = path.join(documentsDir.path, filename);

      final file = File(pickedFile.path);
      final savedFile = await file.copy(imagePath);

      setState(() {
        _imagemUrl = savedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _rendimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produtoController = context.watch<ProdutoController>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEdicao ? 'Editar Receita' : 'Cadastrar Receita'), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
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
                      _buildImageSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome da Receita', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome da receita';
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
                              controller: _rendimentoController,
                              decoration: const InputDecoration(labelText: 'Rendimento', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite o rendimento';
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
                              value: _unidadeRendimento,
                              decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                              items:
                                  _unidadesRendimento.map((unidade) {
                                    return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _unidadeRendimento = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPercentageSlider('Gastos "escondidos"', _percentualGastos, (value) {
                        setState(() {
                          _percentualGastos = value;
                        });
                      }),
                      const SizedBox(height: 16),
                      _buildPercentageSlider('Mão de obra', _percentualMaoDeObra, (value) {
                        setState(() {
                          _percentualMaoDeObra = value;
                        });
                      }),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Ingredientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () => _mostrarDialogoAdicionarIngrediente(context), icon: const Icon(Icons.add), label: const Text('Adicionar'))]),
                      const SizedBox(height: 8),
                      if (_ingredientes.isEmpty)
                        const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhum ingrediente adicionado', textAlign: TextAlign.center)))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ingredientes.length,
                          itemBuilder: (context, index) {
                            final ingrediente = _ingredientes[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(onPressed: (_) => _mostrarDialogoEditarIngrediente(context, ingrediente), backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: 'Editar'),
                                  SlidableAction(
                                    onPressed: (_) {
                                      setState(() {
                                        _ingredientes.removeAt(index);
                                      });
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Remover',
                                  ),
                                ],
                              ),
                              child: Card(child: ListTile(title: Text(ingrediente.produto.nome), subtitle: Text(ingrediente.fracao != null ? '${ingrediente.fracao} ${ingrediente.unidade}' : '${ingrediente.quantidade} ${ingrediente.unidade}'), trailing: Text(MoneyFormatter.formatReal(ingrediente.custoTotal), style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => _mostrarDialogoEditarIngrediente(context, ingrediente))),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      if (_ingredientes.isNotEmpty) ...[const Divider(), const SizedBox(height: 8), _buildResumoReceita(), const SizedBox(height: 24)],
                      ElevatedButton(onPressed: _salvar, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_isEdicao ? 'Atualizar' : 'Cadastrar')),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageSelector() {
    return Column(children: [if (_imagemUrl != null) Container(height: 200, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: _imagemUrl!.startsWith('http') ? NetworkImage(_imagemUrl!) as ImageProvider : FileImage(File(_imagemUrl!)) as ImageProvider, fit: BoxFit.cover))) else Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, size: 64, color: Colors.grey)), const SizedBox(height: 8), ElevatedButton.icon(onPressed: _selecionarImagem, icon: const Icon(Icons.photo_library), label: const Text('Adicionar Foto'))]);
  }

  Widget _buildPercentageSlider(String label, double value, void Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(NumberFormatter.formatPercent(value), style: const TextStyle(fontWeight: FontWeight.bold))]),
        Slider(
          value: value,
          min: 0.0,
          max: 0.5, // Até 50%
          divisions: 10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResumoReceita() {
    final custoIngredientes = _ingredientes.fold<double>(0, (sum, ingrediente) => sum + ingrediente.custoTotal);

    final custoComGastos = custoIngredientes * (1 + _percentualGastos);
    final valorTotal = custoComGastos / (1 - _percentualMaoDeObra);

    final rendimento = double.tryParse(_rendimentoController.text) ?? 1.0;
    final valorUnitario = valorTotal / rendimento;

    return Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Resumo da Precificação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16), _buildResumoItem('Custo dos Ingredientes', MoneyFormatter.formatReal(custoIngredientes)), const Divider(), _buildResumoItem('Gastos "escondidos" (${NumberFormatter.formatPercent(_percentualGastos)})', MoneyFormatter.formatReal(custoIngredientes * _percentualGastos)), const Divider(), _buildResumoItem('Custo com gastos', MoneyFormatter.formatReal(custoComGastos)), const Divider(), _buildResumoItem('Mão de obra (${NumberFormatter.formatPercent(_percentualMaoDeObra)})', MoneyFormatter.formatReal(valorTotal - custoComGastos)), const Divider(), _buildResumoItem('Valor Total', MoneyFormatter.formatReal(valorTotal), destaque: true), const Divider(), _buildResumoItem('Valor por $_unidadeRendimento', MoneyFormatter.formatReal(valorUnitario), destaque: true)])));
  }

  Widget _buildResumoItem(String label, String valor, {bool destaque = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal)), Text(valor, style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal, fontSize: destaque ? 16 : 14))]);
  }

  void _mostrarDialogoAdicionarIngrediente(BuildContext context) {
    final produtoController = context.read<ProdutoController>();

    if (produtoController.produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há produtos cadastrados. Cadastre produtos primeiro.')));
      return;
    }

    Produto? produtoSelecionado = produtoController.produtos.first;
    String unidadeSelecionada = produtoSelecionado.unidade;
    final quantidadeController = TextEditingController();
    String? fracaoSelecionada;

    final unidades = ['kg', 'g', 'L', 'ml', 'unidade', 'colher de sopa', 'colher de chá', 'xícara'];
    final fracoes = ['1', '1/2', '1/3', '1/4', '2/3', '3/4'];

    bool usarFracao = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Adicionar Ingrediente'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Produto>(
                        value: produtoSelecionado,
                        decoration: const InputDecoration(labelText: 'Produto', border: OutlineInputBorder()),
                        items:
                            produtoController.produtos.map((produto) {
                              return DropdownMenuItem<Produto>(value: produto, child: Text(produto.nome));
                            }).toList(),
                        onChanged: (produto) {
                          if (produto != null) {
                            setState(() {
                              produtoSelecionado = produto;
                              // Mantém a unidade anterior se possível, ou usa a do produto
                              if (!unidades.contains(unidadeSelecionada)) {
                                unidadeSelecionada = produto.unidade;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Usar fração:'),
                          Switch(
                            value: usarFracao,
                            onChanged: (value) {
                              setState(() {
                                usarFracao = value;
                                // Limpa o campo de quantidade se mudar para fração
                                if (value) {
                                  quantidadeController.clear();
                                  fracaoSelecionada = '1';
                                } else {
                                  fracaoSelecionada = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (usarFracao)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1',
                                decoration: const InputDecoration(labelText: 'Fração', border: OutlineInputBorder()),
                                items:
                                    fracoes.map((fracao) {
                                      return DropdownMenuItem<String>(value: fracao, child: Text(fracao));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      fracaoSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unidadeSelecionada,
                                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                                items:
                                    unidades.map((unidade) {
                                      return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      unidadeSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: TextFormField(controller: quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))])),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unidadeSelecionada,
                                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                                items:
                                    unidades.map((unidade) {
                                      return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      unidadeSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                  TextButton(
                    onPressed: () {
                      if (!usarFracao && (quantidadeController.text.isEmpty || double.tryParse(quantidadeController.text) == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida.')));
                        return;
                      }

                      if (produtoSelecionado != null) {
                        double quantidade = 0;

                        if (!usarFracao) {
                          quantidade = double.parse(quantidadeController.text);
                        } else if (fracaoSelecionada != null) {
                          // Converter a fração para um valor decimal para cálculos
                          quantidade = Ingrediente.converterFracao(fracaoSelecionada!);
                        }

                        final novoIngrediente = Ingrediente(id: DateTime.now().millisecondsSinceEpoch.toString(), produto: produtoSelecionado!, quantidade: quantidade, unidade: unidadeSelecionada, fracao: usarFracao ? fracaoSelecionada : null);

                        setState(() {
                          _ingredientes.add(novoIngrediente);
                        });

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _mostrarDialogoEditarIngrediente(BuildContext context, Ingrediente ingrediente) {
    final produtoController = context.read<ProdutoController>();

    if (produtoController.produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há produtos cadastrados.')));
      return;
    }

    Produto? produtoSelecionado = ingrediente.produto;
    String unidadeSelecionada = ingrediente.unidade;
    final quantidadeController = TextEditingController(text: ingrediente.fracao == null ? ingrediente.quantidade.toString() : '');
    String? fracaoSelecionada = ingrediente.fracao;

    final unidades = ['kg', 'g', 'L', 'ml', 'unidade', 'colher de sopa', 'colher de chá', 'xícara'];
    final fracoes = ['1', '1/2', '1/3', '1/4', '2/3', '3/4'];

    bool usarFracao = ingrediente.fracao != null;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Editar Ingrediente'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Produto>(
                        value: produtoSelecionado,
                        decoration: const InputDecoration(labelText: 'Produto', border: OutlineInputBorder()),
                        items:
                            produtoController.produtos.map((produto) {
                              return DropdownMenuItem<Produto>(value: produto, child: Text(produto.nome));
                            }).toList(),
                        onChanged: (produto) {
                          if (produto != null) {
                            setState(() {
                              produtoSelecionado = produto;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Usar fração:'),
                          Switch(
                            value: usarFracao,
                            onChanged: (value) {
                              setState(() {
                                usarFracao = value;
                                // Limpa o campo de quantidade se mudar para fração
                                if (value) {
                                  quantidadeController.clear();
                                  fracaoSelecionada = fracoes.contains(ingrediente.fracao) ? ingrediente.fracao : '1';
                                } else {
                                  fracaoSelecionada = null;
                                  if (ingrediente.quantidade > 0) {
                                    quantidadeController.text = ingrediente.quantidade.toString();
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (usarFracao)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1',
                                decoration: const InputDecoration(labelText: 'Fração', border: OutlineInputBorder()),
                                items:
                                    fracoes.map((fracao) {
                                      return DropdownMenuItem<String>(value: fracao, child: Text(fracao));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      fracaoSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unidadeSelecionada,
                                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                                items:
                                    unidades.map((unidade) {
                                      return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      unidadeSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: TextFormField(controller: quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))])),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unidadeSelecionada,
                                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                                items:
                                    unidades.map((unidade) {
                                      return DropdownMenuItem<String>(value: unidade, child: Text(unidade));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      unidadeSelecionada = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                  TextButton(
                    onPressed: () {
                      if (!usarFracao && (quantidadeController.text.isEmpty || double.tryParse(quantidadeController.text) == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida.')));
                        return;
                      }

                      if (produtoSelecionado != null) {
                        double quantidade = 0;

                        if (!usarFracao) {
                          quantidade = double.parse(quantidadeController.text);
                        } else if (fracaoSelecionada != null) {
                          // Converter a fração para um valor decimal para cálculos
                          quantidade = Ingrediente.converterFracao(fracaoSelecionada!);
                        }

                        // Encontrar e substituir o ingrediente
                        final index = _ingredientes.indexWhere((i) => i.id == ingrediente.id);
                        if (index != -1) {
                          setState(() {
                            _ingredientes[index] = Ingrediente(id: ingrediente.id, produto: produtoSelecionado!, quantidade: quantidade, unidade: unidadeSelecionada, fracao: usarFracao ? fracaoSelecionada : null);
                          });
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Atualizar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _salvar() {
    if (_ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um ingrediente à receita.')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      final controller = context.read<ReceitaController>();

      final nome = _nomeController.text;
      final rendimento = double.parse(_rendimentoController.text);

      if (_isEdicao && _receitaOriginal != null) {
        final receitaAtualizada = Receita(id: _receitaOriginal!.id, nome: nome, ingredientes: _ingredientes, percentualGastos: _percentualGastos, percentualMaoDeObra: _percentualMaoDeObra, rendimento: rendimento, unidadeRendimento: _unidadeRendimento, imagemUrl: _imagemUrl, dataUltimaAtualizacao: DateTime.now());

        controller.atualizarReceita(receitaAtualizada);
      } else {
        controller.salvarReceita(nome: nome, ingredientes: _ingredientes, percentualGastos: _percentualGastos, percentualMaoDeObra: _percentualMaoDeObra, rendimento: rendimento, unidadeRendimento: _unidadeRendimento, imagemUrl: _imagemUrl);
      }

      context.pop();
    }
  }
}
