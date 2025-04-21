import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Classe auxiliar para simplificar o uso do image_picker
class ImagePickerHelper {
  /// Constante para seleção de imagem da galeria
  static const int gallery = 0;

  /// Constante para captura de imagem da câmera
  static const int camera = 1;

  /// Seleciona uma imagem da galeria ou câmera do dispositivo
  ///
  /// Parâmetros:
  /// - source: origem da imagem (gallery = 0, camera = 1)
  ///
  /// Retorna um objeto ImageFile ou null se nenhuma imagem for selecionada
  static Future<ImageFile?> pickImage({required int source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source == gallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return ImageFile(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      return null;
    }
  }
}

/// Classe que encapsula o XFile para simplificar o uso
class ImageFile {
  final String path;

  ImageFile(this.path);
}
