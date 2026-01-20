import 'package:flutter/material.dart';

/// Widget que exibe um bottom sheet com opções para adicionar imagem
class ImageOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onSearchTap;

  const ImageOptionsBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Adicionar Imagem', style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeria'),
            onTap: () {
              Navigator.of(context).pop();
              onGalleryTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Câmera'),
            onTap: () {
              Navigator.of(context).pop();
              onCameraTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Buscar online'),
            onTap: () {
              Navigator.of(context).pop();
              onSearchTap();
            },
          ),
        ],
      ),
    );
  }
}

/// Função auxiliar para exibir o bottom sheet de opções de imagem
Future<void> mostrarOpcoesImagem({
  required BuildContext context,
  required VoidCallback onGalleryTap,
  required VoidCallback onCameraTap,
  required VoidCallback onSearchTap,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (context) =>
        ImageOptionsBottomSheet(onGalleryTap: onGalleryTap, onCameraTap: onCameraTap, onSearchTap: onSearchTap),
  );
}
