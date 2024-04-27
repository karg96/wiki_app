import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wiki_app/bloc/bloc_event.dart';
import 'package:wiki_app/bloc/bloc_state.dart';
import 'package:wiki_app/data/repository/wikipedia_repository.dart';

class WikipediaBloc extends Bloc<BlocEvent, BlocState> {
  final WikipediaRepository wikipediaRepository;

  WikipediaBloc({required this.wikipediaRepository}) : super(EmptyState()) {
    on<SearchEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final result = await wikipediaRepository.getSearchResult(event.query);
        if (result.query?.pages != null) {
          emit(QuerySuccessState(searchResult: result));
        } else {
          emit(const ErrorState(message: 'Query returned no result'));
        }
      } catch (e) {
        emit(ErrorState(message: e.toString()));
      }
    }, transformer: debounce(const Duration(microseconds: 500)));

    on<GetContent>((event, emit) async {
      try {
        final result = await wikipediaRepository.getContent(event.title);
        final extract = result.query?.pages?[0].extract;
        if (extract != null) {
          emit(ContentSuccess(extract: extract));
        } else {
          emit(const ErrorState(message: 'No extract found'));
        }
      } catch (e) {
        emit(ErrorState(message: e.toString()));
      }
    });
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
