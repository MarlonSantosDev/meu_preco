import 'dart:io';
import 'package:flutter/material.dart';

/// Widget para seleção e exibição de imagens
class ImageSelector extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final double height;
  final String placeholder;

  const ImageSelector({
    Key? key,
    required this.imageUrl,
    required this.onTap,
    this.height = 200,
    this.placeholder = 'Toque para adicionar imagem',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child:
              imageUrl != null
                  ? Container(
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image:
                            imageUrl!.startsWith('http')
                                ? NetworkImage(imageUrl!) as ImageProvider
                                : FileImage(File(imageUrl!)) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : Container(
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 64, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(placeholder, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Adicionar ou alterar imagem'),
        ),
      ],
    );
  }
}
