import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:wiki_app/bloc/wikipedia_bloc.dart';

import '../data/repository/wikipedia_repository.dart';

final locator = GetIt.instance;

void setupDependencies() {
  locator.registerSingleton((() {
    final cacheManager = DefaultCacheManager();
    const baseUrl = 'https://en.wikipedia.org/w/api.php?';
    final client = http.Client();
    return WikipediaRepository(
        cacheManager: cacheManager, baseUrl: baseUrl, client: client);
  })());

  locator.registerSingleton(WikipediaBloc(
    wikipediaRepository: locator<WikipediaRepository>(),
  ));
}
