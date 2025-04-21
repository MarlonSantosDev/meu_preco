import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Serviço responsável por integração com a API do Unsplash para busca de imagens
class UnsplashService {
  static const String accessKey = 'X1QJMWLXWfCBDBSJUyjjJLWEXiw5aY-uWl0I4YNnP2k';
  static const String baseUrl = 'https://api.unsplash.com';

  /// Busca imagens no Unsplash com base na query fornecida
  ///
  /// Parâmetros:
  /// - query: termos de busca
  /// - perPage: número de resultados por página
  /// - orientation: orientação das imagens (landscape, portrait, squarish)
  /// - category: categoria específica
  /// - language: idioma preferido para resultados
  Future<List<String>> buscarImagens(
    String query, {
    int perPage = 20,
    String orientation = 'landscape',
    String? category,
    String language = 'pt',
  }) async {
    try {
      // Constrói a URL com parâmetros para busca mais relevante
      final queryParams = {
        'query': query,
        'per_page': perPage.toString(),
        'orientation': orientation,
        'content_filter': 'high',
        'lang': language,
      };

      // Adiciona categoria se especificada
      if (category != null && category.isNotEmpty) {
        queryParams['collections'] = category;
      }

      final uri = Uri.parse('$baseUrl/search/photos').replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {'Authorization': 'Client-ID $accessKey'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (kDebugMode) {
          print('Unsplash - Encontradas ${results.length} imagens para "$query"');
          if (results.isNotEmpty) {
            print('Unsplash - Tags relevantes: ${results.first['tags']?.map((t) => t['title']).join(', ')}');
          }
        }

        return results.map((item) => item['urls']['regular'] as String).toList();
      } else {
        if (kDebugMode) {
          print('Unsplash - Erro na API (${response.statusCode}): ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unsplash - Erro ao buscar imagens: $e');
      }
      return [];
    }
  }

  /// Baixa uma imagem a partir da URL fornecida
  Future<http.Response> baixarImagem(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Unsplash - Erro ao baixar imagem: $e');
      }
      rethrow;
    }
  }
}
