import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Classe auxiliar para trabalhar com o pacote image_picker
class ImagePickerHelper {
  // Define constantes para facilitar o uso
  static const int gallery = 0;
  static const int camera = 1;

  /// Método para selecionar uma imagem da galeria ou câmera
  /// source: 0 para galeria, 1 para câmera
  static Future<ImageFile?> pickImage({required int source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source == gallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80, // Qualidade da imagem (0-100)
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

/// Classe que encapsula o XFile para manter a compatibilidade
class ImageFile {
  final String path;

  ImageFile(this.path);

  Future<Uint8List> readAsBytes() async {
    try {
      final file = File(path);
      return await file.readAsBytes();
    } catch (e) {
      // Retorna uma imagem vazia em caso de erro
      return Uint8List(0);
    }
  }

  Future<String> readAsString() async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
