import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/core/utils/image_picker_helper.dart';
import 'package:meu_preco/data/services/unsplash_service.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
import 'package:meu_preco/presentation/widgets/image_selection_dialog.dart';
import 'package:meu_preco/presentation/widgets/image_options_bottom_sheet.dart';
import 'package:meu_preco/presentation/widgets/image_selector.dart';

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

  String _unidade = 'unidade';
  final List<String> _unidades = ['unidade', 'kg', 'g', 'L', 'ml'];

  bool _isEdicao = false;
  bool _carregando = true;
  bool _buscandoImagens = false;
  String? _erro;
  String? _imagemUrl;
  Produto? _produtoOriginal;
  final UnsplashService _unsplashService = UnsplashService();
  List<String> _imagensEncontradas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (widget.produtoId != null) {
      _isEdicao = true;
      try {
        final controller = context.read<ProdutoController>();
        final produto = await controller.obterProdutoPorId(widget.produtoId!);

        if (produto != null) {
          setState(() {
            _nomeController.text = produto.nome;
            _precoController.text = produto.preco.toString();
            _quantidadeController.text = produto.quantidade.toString();
            _unidade = produto.unidade;
            _imagemUrl = produto.imagemUrl;
            _produtoOriginal = produto;
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

  Future<void> _selecionarImagem() async {
    try {
      final pickedFile = await ImagePickerHelper.pickImage(source: ImagePickerHelper.gallery);

      if (pickedFile != null) {
        // Copiar a imagem para um local permanente
        final documentsDir = await getApplicationDocumentsDirectory();
        final filename = 'produto_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
        final filename = 'produto_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      ).showSnackBar(const SnackBar(content: Text('Digite o nome do produto para buscar imagens')));
      return;
    }

    setState(() {
      _buscandoImagens = true;
    });

    try {
      // Otimização da query para melhorar relevância das imagens
      String query = '${_nomeController.text} alimento';
      // Adiciona termos específicos com base na unidade selecionada
      if (_unidade == 'kg' || _unidade == 'g') {
        query += ' ingrediente';
      } else if (_unidade == 'L' || _unidade == 'ml') {
        query += ' bebida líquido';
      }

      final imagens = await _unsplashService.buscarImagens(query, perPage: 30, category: 'food');

      setState(() {
        _imagensEncontradas = imagens;
        _buscandoImagens = false;
      });

      if (imagens.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nenhuma imagem encontrada para este produto')));
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
        final filename = 'produto_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    mostrarDialogoSelecaoImagem(
      context: context,
      imagens: imagens,
      title: 'Selecione uma imagem para o produto',
      onImageSelected: _salvarImagemDaWeb,
    );
  }

  void _mostrarOpcoesImagem() {
    mostrarOpcoesImagem(
      context: context,
      onGalleryTap: _selecionarImagem,
      onCameraTap: _tirarFoto,
      onSearchTap: _buscarImagens,
    );
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
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Produto' : 'Cadastrar Produto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                        decoration: const InputDecoration(labelText: 'Nome do Produto', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome do produto';
                          }

                          // Verificar se já existe um produto com este nome
                          final controller = context.read<ProdutoController>();
                          if (controller.existeProdutoComNome(
                            value,
                            idIgnorar: _isEdicao ? _produtoOriginal?.id : null,
                          )) {
                            return 'Já existe um produto com este nome';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precoController,
                        decoration: const InputDecoration(labelText: 'Preço (R\$)', border: OutlineInputBorder()),
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
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  return 'Digite uma quantidade válida';
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
                      const SizedBox(height: 24),
                      if (_isEdicao) _buildPrecoUnitario(),
                      const SizedBox(height: 16),
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

  Widget _buildImageSelector() {
    return ImageSelector(
      imageUrl: _imagemUrl,
      onTap: _mostrarOpcoesImagem,
      placeholder: 'Toque para adicionar imagem do produto',
    );
  }

  Widget _buildPrecoUnitario() {
    final precoValue = double.tryParse(_precoController.text) ?? 0;
    final quantidadeValue = double.tryParse(_quantidadeController.text) ?? 1;

    if (quantidadeValue <= 0) return const SizedBox.shrink();

    final precoUnitario = precoValue / quantidadeValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo do Preço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preço unitário:'),
                Text(MoneyFormatter.formatReal(precoUnitario), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Preço por $_unidade:'),
                Text(MoneyFormatter.formatReal(precoUnitario), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      try {
        final controller = context.read<ProdutoController>();

        final nome = _nomeController.text;
        final precoTexto = _precoController.text.replaceAll('R\$', '').trim();
        final precoFormatado =
            precoTexto.contains(',') ? precoTexto.replaceAll('.', '').replaceAll(',', '.') : precoTexto;

        final preco = double.parse(precoFormatado);
        final quantidade = double.parse(_quantidadeController.text);

        if (_isEdicao && _produtoOriginal != null) {
          // Verificar se o preço foi alterado
          bool precoAlterado = _produtoOriginal!.preco != preco;

          // Atualizar o produto
          final produtoAtualizado = Produto(
            id: _produtoOriginal!.id,
            nome: nome,
            preco: preco,
            quantidade: quantidade,
            unidade: _unidade,
            imagemUrl: _imagemUrl,
          );
          controller.atualizarProduto(produtoAtualizado);

          // Se o preço foi alterado, mostrar um SnackBar informando que as receitas serão atualizadas
          if (precoAlterado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receitas que utilizam este produto terão seus preços atualizados automaticamente.'),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          controller.salvarProduto(
            nome: nome,
            preco: preco,
            quantidade: quantidade,
            unidade: _unidade,
            imagemUrl: _imagemUrl,
          );
        }

        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar produto: $e')));
      }
    }
  }
}
