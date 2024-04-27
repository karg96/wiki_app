import 'dart:convert';

import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import '../model/search_result.dart';

class WikipediaRepository {
  final CacheManager cacheManager;
  final String baseUrl;
  final http.Client client;

  WikipediaRepository({required this.cacheManager, required this.baseUrl, required this.client});

  Future<SearchResult> getSearchResult(String query) async {
    try {
      String url =
          "${baseUrl}action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpslimit=10&&gpssearch=${Uri.encodeQueryComponent(query)}";
      print(url);
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



  Future<SearchResult> getContent(String title) async {
    try {
      String url =
          "${baseUrl}action=query&format=json&prop=pageimages%7Cpageterms%7Cextracts&formatversion=2&titles=${Uri.encodeQueryComponent(title)}";
      print("URL: $url");
      File file = await cacheManager
          .getSingleFile(url, headers: {'Cache-Control': 'max-age=3600'}, key: title);
      String data = await file.readAsString();
      print(data);
      return SearchResult.fromJson(jsonDecode(data));
    } catch (e) {
      throw Exception("Something went wrong: ${e.toString()}");
    }
  }
}
