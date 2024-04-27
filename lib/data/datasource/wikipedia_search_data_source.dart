import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/search_result.dart';

class WikipediaSearchDataSource {
  final http.Client client;

  WikipediaSearchDataSource({required this.client});

  Future<SearchResult> search(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return SearchResult.fromJson(json.decode(response.body));
      } else {
        throw Exception("Network error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Something went wrong: ${e.toString()}");
    }
  }
}
