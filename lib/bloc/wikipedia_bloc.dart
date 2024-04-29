import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wiki_app/bloc/bloc_event.dart';
import 'package:wiki_app/bloc/bloc_state.dart';
import 'package:wiki_app/data/repository/wikipedia_repository.dart';

import '../data/model/search_result.dart';

class WikipediaBloc extends Bloc<BlocEvent, BlocState> {
  final WikipediaRepository wikipediaRepository;
  SearchResult? _searchResult;

  WikipediaBloc({required this.wikipediaRepository}) : super(EmptyState()) {
    on<CheckConnectivity>((event, emit) async {
      try {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());
        if (!connectivityResult.contains(ConnectivityResult.wifi) &&
            !connectivityResult.contains(ConnectivityResult.mobile)) {
          emit(LoadingState());
          final offlineSearchResults =
              await wikipediaRepository.fetchCachedData();
          emit(OfflineState(searchResult: offlineSearchResults));
        } else {
          _searchResult == null
              ? emit(EmptyState())
              : emit(QuerySuccessState(searchResult: _searchResult!));
        }
      } catch (e) {
        _onError(emit, e);
      }
    });

    on<SearchEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final result = await wikipediaRepository.getSearchResult(event.query);
        if (result.query?.pages != null) {
          _searchResult = result;
          emit(QuerySuccessState(searchResult: result));
        } else {
          emit(const ErrorState(message: 'Query returned no result'));
        }
      } catch (e) {
        _onError(emit, e);
      }
    }, transformer: debounce(const Duration(milliseconds: 500)));

    on<GetContent>((event, emit) async {
      try {
        final result = await wikipediaRepository.getContent(event.title);
        final page = result.query?.pages?.first;
        if (page != null) {
          emit(ContentSuccess(page: page));
        } else {
          emit(const ErrorState(message: 'No extract found'));
        }
      } catch (e) {
        _onError(emit, e);
      }
    });
  }

  void _onError(Emitter<BlocState> emit, Object e) {
    emit(ErrorState(message: e.toString()));
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
