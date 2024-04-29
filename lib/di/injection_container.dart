import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiki_app/bloc/wikipedia_bloc.dart';

import '../data/repository/wikipedia_repository.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  final cacheManager = DefaultCacheManager();
  const baseUrl = 'https://en.wikipedia.org/w/api.php?';
  final client = http.Client();
  final prefs = await SharedPreferences.getInstance();

  locator.registerSingleton(cacheManager);
  locator.registerSingleton(client);
  locator.registerSingleton(prefs);

  locator.registerLazySingleton(() => WikipediaRepository(
    cacheManager: locator<DefaultCacheManager>(),
    baseUrl: baseUrl,
    client: locator<http.Client>(),
    prefs: locator<SharedPreferences>(),
  ));

  locator.registerFactory(() => WikipediaBloc(
    wikipediaRepository: locator<WikipediaRepository>(),
  ));
}
