import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:meu_preco/core/utils/formatters.dart';
import 'package:meu_preco/core/utils/image_picker_helper.dart';
import 'package:meu_preco/data/services/unsplash_service.dart';
import 'package:meu_preco/domain/entities/produto.dart';
import 'package:meu_preco/presentation/controllers/produto_controller.dart';
// import 'package:image_picker/image_picker.dart'; // Temporariamente comentado

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
  // Não precisamos de uma instância do helper pois usamos métodos estáticos

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite o nome do produto para buscar imagens')));
      return;
    }

    setState(() {
      _buscandoImagens = true;
    });

    try {
      final imagens = await _unsplashService.buscarImagens(_nomeController.text);

      setState(() {
        _imagensEncontradas = imagens;
        _buscandoImagens = false;
      });

      if (imagens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma imagem encontrada para este produto')));
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Selecione uma imagem'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
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
                          return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
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
                      _buildImageSelector(),
                      const SizedBox(height: 16),
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
                      ElevatedButton(onPressed: _salvar, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_isEdicao ? 'Atualizar' : 'Cadastrar')),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      children: [
        GestureDetector(onTap: _mostrarOpcoesImagem, child: _imagemUrl != null ? Container(height: 200, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: _imagemUrl!.startsWith('http') ? NetworkImage(_imagemUrl!) as ImageProvider : FileImage(File(_imagemUrl!)) as ImageProvider, fit: BoxFit.cover))) : Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.image, size: 64, color: Colors.grey), SizedBox(height: 8), Text('Toque para adicionar imagem', style: TextStyle(color: Colors.grey))]))),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: _mostrarOpcoesImagem, icon: const Icon(Icons.add_photo_alternate), label: const Text('Adicionar ou alterar imagem')),
      ],
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Preço unitário:'), Text(MoneyFormatter.formatReal(precoUnitario), style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Preço por $_unidade:'), Text(MoneyFormatter.formatReal(precoUnitario), style: const TextStyle(fontWeight: FontWeight.bold))]),
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
        final precoFormatado = precoTexto.contains(',') ? precoTexto.replaceAll('.', '').replaceAll(',', '.') : precoTexto;

        final preco = double.parse(precoFormatado);
        final quantidade = double.parse(_quantidadeController.text);

        if (_isEdicao && _produtoOriginal != null) {
          // Verificar se o preço foi alterado
          bool precoAlterado = _produtoOriginal!.preco != preco;

          // Atualizar o produto
          final produtoAtualizado = Produto(id: _produtoOriginal!.id, nome: nome, preco: preco, quantidade: quantidade, unidade: _unidade, imagemUrl: _imagemUrl);
          controller.atualizarProduto(produtoAtualizado);

          // Se o preço foi alterado, mostrar um SnackBar informando que as receitas serão atualizadas
          if (precoAlterado) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receitas que utilizam este produto terão seus preços atualizados automaticamente.'), duration: Duration(seconds: 4), backgroundColor: Colors.green));
          }
        } else {
          controller.salvarProduto(nome: nome, preco: preco, quantidade: quantidade, unidade: _unidade, imagemUrl: _imagemUrl);
        }

        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar produto: $e')));
      }
    }
  }
}
