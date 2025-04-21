import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/core/utils/image_picker_helper.dart';
import 'package:meu_preco/data/services/unsplash_service.dart';
import 'package:meu_preco/domain/entities/ingrediente.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/domain/entities/receita.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:meu_preco/presentation/controllers/receita_controller.dart';
import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart'; // Temporariamente comentado

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
  bool _buscandoImagens = false;
  String? _erro;
  String? _imagemUrl;

  Receita? _receitaOriginal;
  List<Ingrediente> _ingredientes = [];
  final UnsplashService _unsplashService = UnsplashService();
  List<String> _imagensEncontradas = [];
  // Não precisamos de uma instância do helper pois usamos métodos estáticos

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
    try {
      final pickedFile = await ImagePickerHelper.pickImage(source: ImagePickerHelper.gallery);

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  Future<void> _tirarFoto() async {
    try {
      final pickedFile = await ImagePickerHelper.pickImage(source: ImagePickerHelper.camera);

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao tirar foto: $e')));
    }
  }

  Future<void> _buscarImagens() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite o nome da receita para buscar imagens')));
      return;
    }

    setState(() {
      _buscandoImagens = true;
    });

    try {
      final imagens = await _unsplashService.buscarImagens('${_nomeController.text} food');

      setState(() {
        _imagensEncontradas = imagens;
        _buscandoImagens = false;
      });

      if (imagens.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nenhuma imagem encontrada para esta receita')));
        return;
      }

      // Exibir diálogo com as imagens encontradas
      _mostrarDialogoSelecaoImagem(imagens);
    } catch (e) {
      setState(() {
        _buscandoImagens = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar imagens: $e')));
    }
  }

  Future<void> _salvarImagemDaWeb(String imageUrl) async {
    try {
      final response = await _unsplashService.baixarImagem(imageUrl);

      if (response.statusCode == 200) {
        final documentsDir = await getApplicationDocumentsDirectory();
        final filename = 'receita_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = path.join(documentsDir.path, filename);

        final file = File(imagePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _imagemUrl = file.path;
        });
      } else {
        throw Exception('Falha ao baixar a imagem: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar imagem: $e')));
    }
  }

  void _mostrarDialogoSelecaoImagem(List<String> imagens) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Selecione uma imagem'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: imagens.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _salvarImagemDaWeb(imagens[index]);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imagens[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar'))],
          ),
    );
  }

  void _mostrarOpcoesImagem() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeria'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selecionarImagem();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _tirarFoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Buscar online'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _buscarImagens();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: _mostrarOpcoesImagem,
          child:
              _imagemUrl != null
                  ? Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image:
                            _imagemUrl!.startsWith('http')
                                ? NetworkImage(_imagemUrl!) as ImageProvider
                                : FileImage(File(_imagemUrl!)) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Toque para adicionar imagem', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _mostrarOpcoesImagem,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Adicionar ou alterar imagem'),
        ),
      ],
    );
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
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Receita' : 'Cadastrar Receita'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _salvar, icon: const Icon(Icons.save))],
      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ingredientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => _mostrarDialogoAdicionarIngrediente(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_ingredientes.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Nenhum ingrediente adicionado', textAlign: TextAlign.center),
                          ),
                        )
                      else
                        ListView.builder(
                          key: ValueKey(_ingredientes.length),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ingredientes.length,
                          itemBuilder: (context, index) {
                            final ingrediente = _ingredientes[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _mostrarDialogoEditarIngrediente(context, ingrediente),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Editar',
                                  ),
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
                              child: Card(
                                child: ListTile(
                                  title: Text(ingrediente.produto.nome),
                                  subtitle: Text(
                                    ingrediente.fracao != null
                                        ? '${ingrediente.fracao} ${ingrediente.unidade}'
                                        : '${ingrediente.quantidade} ${ingrediente.unidade}',
                                  ),
                                  trailing: Text(
                                    MoneyFormatter.formatReal(ingrediente.custoTotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () => _mostrarDialogoEditarIngrediente(context, ingrediente),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      if (_ingredientes.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildResumoReceita(),
                        const SizedBox(height: 24),
                      ],
                      ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(_isEdicao ? 'Atualizar' : 'Cadastrar'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPercentageSlider(String label, double value, void Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(NumberFormatter.formatPercent(value), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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

    final valorGastosEscondidos = custoIngredientes * _percentualGastos;
    final valorMaoDeObra = custoIngredientes * _percentualMaoDeObra;
    final percentualTotal = _percentualGastos + _percentualMaoDeObra;
    final valorPercentuais = custoIngredientes * percentualTotal;
    final valorLucro = custoIngredientes; // 100% do custo dos ingredientes

    final valorTotal = custoIngredientes + valorPercentuais + valorLucro;

    final rendimento = double.tryParse(_rendimentoController.text) ?? 1.0;
    final valorUnitario = rendimento > 0 ? valorTotal / rendimento : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo da Precificação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildResumoItem('Custo dos Ingredientes', MoneyFormatter.formatReal(custoIngredientes)),
            const Divider(),
            _buildResumoItem(
              'Gastos "escondidos" (${NumberFormatter.formatPercent(_percentualGastos)})',
              MoneyFormatter.formatReal(valorGastosEscondidos),
            ),
            const Divider(),
            _buildResumoItem(
              'Mão de obra (${NumberFormatter.formatPercent(_percentualMaoDeObra)})',
              MoneyFormatter.formatReal(valorMaoDeObra),
            ),
            const Divider(),
            _buildResumoItem(
              'Total percentuais (${NumberFormatter.formatPercent(percentualTotal)})',
              MoneyFormatter.formatReal(valorPercentuais),
            ),
            const Divider(),
            _buildResumoItem('Lucro (100%)', MoneyFormatter.formatReal(valorLucro)),
            const Divider(),
            _buildResumoItem('Valor Total', MoneyFormatter.formatReal(valorTotal), destaque: true),
            const Divider(),
            _buildResumoItem('Valor por $_unidadeRendimento', MoneyFormatter.formatReal(valorUnitario), destaque: true),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, {bool destaque = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal)),
        Text(
          valor,
          style: TextStyle(fontWeight: destaque ? FontWeight.bold : FontWeight.normal, fontSize: destaque ? 16 : 14),
        ),
      ],
    );
  }

  void _mostrarDialogoAdicionarIngrediente(BuildContext context) {
    final produtoController = context.read<ProdutoController>();

    if (produtoController.produtos.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Não há produtos cadastrados. Cadastre produtos primeiro.')));
      return;
    }

    // Filtrar os produtos que já estão na receita
    final produtosDisponiveis =
        produtoController.produtos.where((produto) => !_ingredientes.any((i) => i.produto.id == produto.id)).toList();

    if (produtosDisponiveis.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Todos os produtos já foram adicionados a esta receita.')));
      return;
    }

    Produto? produtoSelecionado = produtosDisponiveis.first;
    String unidadeSelecionada = produtoSelecionado.unidade;
    final quantidadeController = TextEditingController();
    String? fracaoSelecionada;
    final inteiroController = TextEditingController(text: "0");

    final unidades = [
      'kg',
      'g',
      'L',
      'ml',
      'unidade',
      'colher de sopa',
      'colher de chá',
      'xícara de chá',
      'xícara de café',
      'copo americano',
    ];
    final fracoes = ['1/2', '1/3', '1/4', '2/3', '3/4'];
    final unidadesComFracao = ['colher de sopa', 'colher de chá', 'xícara de chá', 'xícara de café', 'copo americano'];

    bool usarFracao = false;
    bool usarMisto = false;
    bool unidadePermiteFracao = unidadesComFracao.contains(unidadeSelecionada);

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
                            produtosDisponiveis.map((produto) {
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
                              // Verifica se a unidade selecionada permite fração
                              unidadePermiteFracao = unidadesComFracao.contains(unidadeSelecionada);
                              // Se a unidade não permitir fração, desabilita a opção
                              if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                usarFracao = false;
                                usarMisto = false;
                                fracaoSelecionada = null;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (unidadePermiteFracao) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('Tipo de Medida:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(value: 'decimal', label: Text('Decimal')),
                            ButtonSegment<String>(value: 'fracao', label: Text('Fração')),
                            ButtonSegment<String>(value: 'misto', label: Text('Misto')),
                          ],
                          selected: {usarMisto ? 'misto' : (usarFracao ? 'fracao' : 'decimal')},
                          onSelectionChanged: (Set<String> selection) {
                            setState(() {
                              final selected = selection.first;
                              if (selected == 'decimal') {
                                usarFracao = false;
                                usarMisto = false;
                                fracaoSelecionada = null;
                              } else if (selected == 'fracao') {
                                usarFracao = true;
                                usarMisto = false;
                                fracaoSelecionada = '1/2';
                                quantidadeController.clear();
                              } else if (selected == 'misto') {
                                usarFracao = false;
                                usarMisto = true;
                                fracaoSelecionada = '1/2';
                                inteiroController.text = '1';
                                quantidadeController.clear();
                              }
                            });
                          },
                        ),
                      ],
                      if (!unidadePermiteFracao)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'A opção de fração só está disponível para medidas como xícaras, copos e colheres',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (usarMisto)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: inteiroController,
                                decoration: const InputDecoration(labelText: 'Inteiro', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1/2',
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
                              flex: 2,
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else if (usarFracao)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1/2',
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
                              flex: 2,
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
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
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: quantidadeController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantidade',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
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
                      if (!usarFracao &&
                          !usarMisto &&
                          (quantidadeController.text.isEmpty || double.tryParse(quantidadeController.text) == null)) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida.')));
                        return;
                      }

                      if (usarMisto &&
                          (inteiroController.text.isEmpty || int.tryParse(inteiroController.text) == null)) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Digite um valor inteiro válido.')));
                        return;
                      }

                      if (produtoSelecionado != null) {
                        double quantidade = 0;
                        String? exibicaoFracao;

                        if (usarMisto) {
                          // Pegar o inteiro e a fração
                          int inteiro = int.parse(inteiroController.text);
                          double fracaoValor = Ingrediente.converterFracao(fracaoSelecionada!);
                          quantidade = inteiro + fracaoValor;
                          exibicaoFracao = "$inteiro e $fracaoSelecionada";
                        } else if (usarFracao) {
                          // Usar apenas a fração
                          quantidade = Ingrediente.converterFracao(fracaoSelecionada!);
                          exibicaoFracao = fracaoSelecionada;
                        } else {
                          // Usar apenas o valor decimal
                          quantidade = double.parse(quantidadeController.text);
                        }

                        final novoIngrediente = Ingrediente(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          produto: produtoSelecionado!,
                          quantidade: quantidade,
                          unidade: unidadeSelecionada,
                          fracao: exibicaoFracao,
                        );

                        // Fecha o diálogo e adiciona o ingrediente
                        Navigator.of(context).pop(novoIngrediente);
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          ),
    ).then((novoIngrediente) {
      if (novoIngrediente != null) {
        // Usar setState diretamente na classe principal
        setState(() {
          _ingredientes.add(novoIngrediente);
        });
      }
    });
  }

  void _mostrarDialogoEditarIngrediente(BuildContext context, Ingrediente ingrediente) {
    final produtoController = context.read<ProdutoController>();

    if (produtoController.produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há produtos cadastrados.')));
      return;
    }

    Produto? produtoSelecionado = ingrediente.produto;
    String unidadeSelecionada = ingrediente.unidade;
    final quantidadeController = TextEditingController(
      text: ingrediente.fracao == null ? ingrediente.quantidade.toString() : '',
    );
    String? fracaoSelecionada;
    final inteiroController = TextEditingController(text: "0");

    final unidades = [
      'kg',
      'g',
      'L',
      'ml',
      'unidade',
      'colher de sopa',
      'colher de chá',
      'xícara de chá',
      'xícara de café',
      'copo americano',
    ];
    final fracoes = ['1/2', '1/3', '1/4', '2/3', '3/4'];
    final unidadesComFracao = ['colher de sopa', 'colher de chá', 'xícara de chá', 'xícara de café', 'copo americano'];

    bool usarFracao = false;
    bool usarMisto = false;
    bool unidadePermiteFracao = unidadesComFracao.contains(unidadeSelecionada);

    // Determinar o tipo de entrada com base no ingrediente atual
    if (ingrediente.fracao != null) {
      if (ingrediente.fracao!.contains('e')) {
        // É um valor misto (1 e 1/2)
        usarMisto = true;
        final partes = ingrediente.fracao!.split(' e ');
        if (partes.length == 2) {
          inteiroController.text = partes[0];
          fracaoSelecionada = partes[1];
        }
      } else {
        // É uma fração simples
        usarFracao = true;
        fracaoSelecionada = ingrediente.fracao;
      }
    } else {
      // É um valor decimal
      quantidadeController.text = ingrediente.quantidade.toString();
    }

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
                            produtoController.produtos
                                .where(
                                  (produto) =>
                                      produto.id == ingrediente.produto.id ||
                                      !_ingredientes.any((i) => i.produto.id == produto.id),
                                )
                                .map((produto) {
                                  return DropdownMenuItem<Produto>(value: produto, child: Text(produto.nome));
                                })
                                .toList(),
                        onChanged: (produto) {
                          if (produto != null) {
                            setState(() {
                              produtoSelecionado = produto;
                              // Verifica se a unidade selecionada permite fração
                              unidadePermiteFracao = unidadesComFracao.contains(unidadeSelecionada);
                              // Se a unidade não permitir fração, desabilita a opção
                              if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                usarFracao = false;
                                usarMisto = false;
                                fracaoSelecionada = null;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (unidadePermiteFracao) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('Tipo de Medida:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(value: 'decimal', label: Text('Decimal')),
                            ButtonSegment<String>(value: 'fracao', label: Text('Fração')),
                            ButtonSegment<String>(value: 'misto', label: Text('Misto')),
                          ],
                          selected: {usarMisto ? 'misto' : (usarFracao ? 'fracao' : 'decimal')},
                          onSelectionChanged: (Set<String> selection) {
                            setState(() {
                              final selected = selection.first;
                              if (selected == 'decimal') {
                                usarFracao = false;
                                usarMisto = false;
                                fracaoSelecionada = null;
                                if (ingrediente.quantidade > 0) {
                                  quantidadeController.text = ingrediente.quantidade.toString();
                                }
                              } else if (selected == 'fracao') {
                                usarFracao = true;
                                usarMisto = false;
                                fracaoSelecionada = fracoes.contains(ingrediente.fracao) ? ingrediente.fracao : '1/2';
                                quantidadeController.clear();
                              } else if (selected == 'misto') {
                                usarFracao = false;
                                usarMisto = true;
                                // Tentar usar valores existentes
                                if (ingrediente.fracao != null && ingrediente.fracao!.contains('e')) {
                                  final partes = ingrediente.fracao!.split(' e ');
                                  if (partes.length == 2) {
                                    inteiroController.text = partes[0];
                                    fracaoSelecionada = partes[1];
                                  } else {
                                    inteiroController.text = '1';
                                    fracaoSelecionada = '1/2';
                                  }
                                } else {
                                  inteiroController.text = '1';
                                  fracaoSelecionada = '1/2';
                                }
                                quantidadeController.clear();
                              }
                            });
                          },
                        ),
                      ],
                      if (!unidadePermiteFracao)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'A opção de fração só está disponível para medidas como xícaras, copos e colheres',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (usarMisto)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: inteiroController,
                                decoration: const InputDecoration(labelText: 'Inteiro', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1/2',
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
                              flex: 2,
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      else if (usarFracao)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: fracaoSelecionada ?? '1/2',
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
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
                            Expanded(
                              child: TextFormField(
                                controller: quantidadeController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantidade',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
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
                                      // Verifica se a nova unidade permite fração
                                      unidadePermiteFracao = unidadesComFracao.contains(value);
                                      // Se a unidade não permitir fração, desabilita a opção
                                      if (!unidadePermiteFracao && (usarFracao || usarMisto)) {
                                        usarFracao = false;
                                        usarMisto = false;
                                        fracaoSelecionada = null;
                                      }
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
                      if (!usarFracao &&
                          !usarMisto &&
                          (quantidadeController.text.isEmpty || double.tryParse(quantidadeController.text) == null)) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida.')));
                        return;
                      }

                      if (usarMisto &&
                          (inteiroController.text.isEmpty || int.tryParse(inteiroController.text) == null)) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Digite um valor inteiro válido.')));
                        return;
                      }

                      if (produtoSelecionado != null) {
                        double quantidade = 0;
                        String? exibicaoFracao;

                        if (usarMisto) {
                          // Pegar o inteiro e a fração
                          int inteiro = int.parse(inteiroController.text);
                          double fracaoValor = Ingrediente.converterFracao(fracaoSelecionada!);
                          quantidade = inteiro + fracaoValor;
                          exibicaoFracao = "$inteiro e $fracaoSelecionada";
                        } else if (usarFracao) {
                          // Usar apenas a fração
                          quantidade = Ingrediente.converterFracao(fracaoSelecionada!);
                          exibicaoFracao = fracaoSelecionada;
                        } else {
                          // Usar apenas o valor decimal
                          quantidade = double.parse(quantidadeController.text);
                        }

                        // Encontrar e substituir o ingrediente
                        final index = _ingredientes.indexWhere((i) => i.id == ingrediente.id);
                        if (index != -1) {
                          // Cria o ingrediente atualizado e retorna no pop
                          final ingredienteAtualizado = Ingrediente(
                            id: ingrediente.id,
                            produto: produtoSelecionado!,
                            quantidade: quantidade,
                            unidade: unidadeSelecionada,
                            fracao: exibicaoFracao,
                          );

                          Navigator.of(context).pop({'index': index, 'ingrediente': ingredienteAtualizado});
                        }
                      }
                    },
                    child: const Text('Atualizar'),
                  ),
                ],
              );
            },
          ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final int index = result['index'];
        final Ingrediente ingredienteAtualizado = result['ingrediente'];

        setState(() {
          _ingredientes[index] = ingredienteAtualizado;
        });
      }
    });
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      try {
        if (_ingredientes.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um ingrediente à receita')));
          return;
        }

        final controller = context.read<ReceitaController>();
        final nome = _nomeController.text;
        final rendimento = double.parse(_rendimentoController.text);

        if (_isEdicao && _receitaOriginal != null) {
          final receitaAtualizada = Receita(
            id: _receitaOriginal!.id,
            nome: nome,
            ingredientes: _ingredientes,
            percentualGastos: _percentualGastos,
            percentualMaoDeObra: _percentualMaoDeObra,
            rendimento: rendimento,
            unidadeRendimento: _unidadeRendimento,
            imagemUrl: _imagemUrl,
            dataUltimaAtualizacao: DateTime.now(),
          );

          controller.atualizarReceita(receitaAtualizada);
        } else {
          controller.salvarReceita(
            nome: nome,
            ingredientes: _ingredientes,
            percentualGastos: _percentualGastos,
            percentualMaoDeObra: _percentualMaoDeObra,
            rendimento: rendimento,
            unidadeRendimento: _unidadeRendimento,
            imagemUrl: _imagemUrl,
          );
        }

        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar receita: $e')));
      }
    }
  }
}
