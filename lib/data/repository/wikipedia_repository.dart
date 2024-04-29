import 'dart:convert';

import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/search_result.dart';

class WikipediaRepository {
  final CacheManager cacheManager;
  final String baseUrl;
  final http.Client client;
  final SharedPreferences prefs;

  WikipediaRepository(
      {required this.cacheManager, required this.baseUrl, required this.client, required this.prefs});

  Future<SearchResult> getSearchResult(String query) async {
    try {
      String url =
          "${baseUrl}action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpslimit=10&&gpssearch=${Uri
          .encodeQueryComponent(query)}";
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
          "${baseUrl}action=query&format=json&prop=pageimages%7Cpageterms%7Cextracts&formatversion=2&titles=${Uri
          .encodeQueryComponent(title)}";
      await _saveKeys(title);
      File file = await cacheManager
          .getSingleFile(
          url, headers: {'Cache-Control': 'max-age=36000'}, key: title);
      String data = await file.readAsString();
      return SearchResult.fromJson(jsonDecode(data));
    } catch (e) {
      throw Exception("Something went wrong: ${e.toString()}");
    }
  }

  _saveKeys(String key) async {
    List<String> keys = prefs.getStringList('keys') ?? [];

    // Add the new key to the list if it doesn't exist
    if (!keys.contains(key)) {
      keys.add(key);
      await prefs.setStringList('keys', keys);
    }
  }

  Future<SearchResult> fetchCachedData() async {
    final cacheKeys = prefs.getStringList('keys') ?? [];

    final searchResults = await Future.wait<SearchResult?>(
        cacheKeys.map((key) async {
          final fileInfo = await cacheManager.getSingleFile(key);
          try {
            final fileContent = await fileInfo.readAsString();
            return SearchResult.fromJson(jsonDecode(fileContent));
          } catch (e) {
            throw Exception('Error fetching data from cache: $e');
          }
        }));

    final pages = searchResults
        .whereType<SearchResult>()
        .map((sr) => sr.query?.pages?.first)
        .where((page) => page != null)
        .cast<Page?>()
        .toList();

    return SearchResult(query: Query(pages: pages));
  }
}
