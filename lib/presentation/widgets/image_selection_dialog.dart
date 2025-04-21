import 'package:flutter/material.dart';

/// Widget para exibir diálogo de seleção de imagens do Unsplash
class ImageSelectionDialog extends StatelessWidget {
  final List<String> imagens;
  final Function(String) onImageSelected;
  final String title;

  const ImageSelectionDialog({
    Key? key,
    required this.imagens,
    required this.onImageSelected,
    this.title = 'Selecione uma imagem',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Altura maior para mostrar mais imagens
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Mostrando ${imagens.length} resultados', style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, // Proporção melhor para visualização
                ),
                itemCount: imagens.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onImageSelected(imagens[index]);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
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
                        // Efeito de hover
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Navigator.of(context).pop();
                                onImageSelected(imagens[index]);
                              },
                              splashColor: Colors.black26,
                              highlightColor: Colors.black12,
                              child: Container(),
                            ),
                          ),
                        ),
                        // Indicação visual de seleção
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar'))],
    );
  }
}

/// Função auxiliar para exibir o diálogo de seleção de imagens
Future<void> mostrarDialogoSelecaoImagem({
  required BuildContext context,
  required List<String> imagens,
  required Function(String) onImageSelected,
  String title = 'Selecione uma imagem',
}) {
  return showDialog(
    context: context,
    builder: (context) => ImageSelectionDialog(imagens: imagens, onImageSelected: onImageSelected, title: title),
  );
}
