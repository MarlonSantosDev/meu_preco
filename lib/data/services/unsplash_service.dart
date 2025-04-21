import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UnsplashService {
  static const String accessKey = 'X1QJMWLXWfCBDBSJUyjjJLWEXiw5aY-uWl0I4YNnP2k';
  static const String baseUrl = 'https://api.unsplash.com';

  Future<List<String>> buscarImagens(String query, {int perPage = 10}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/photos?query=${Uri.encodeComponent(query)}&per_page=$perPage'), headers: {'Authorization': 'Client-ID $accessKey'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (kDebugMode) {
          print('Unsplash - Encontradas ${results.length} imagens para "$query"');
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
