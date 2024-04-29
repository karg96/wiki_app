import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:wiki_app/bloc/bloc_event.dart';
import 'package:wiki_app/bloc/wikipedia_bloc.dart';
import 'package:wiki_app/data/model/search_result.dart';
import 'package:wiki_app/data/repository/wikipedia_repository.dart';
import 'package:wiki_app/pages/home_page.dart';

import 'di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wikipedia',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: BlocProvider(
        create: (context)=>locator<WikipediaBloc>()..add(CheckConnectivity()), child: HomePage(),
      ),
    );
  }
}
