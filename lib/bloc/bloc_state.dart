import 'package:equatable/equatable.dart';
import 'package:wiki_app/data/model/search_result.dart';

class BlocState extends Equatable {
  const BlocState();

  @override
  List<Object?> get props => [];
}

class EmptyState extends BlocState {}

class LoadingState extends BlocState {}

class QuerySuccessState extends BlocState {
  final SearchResult searchResult;

  const QuerySuccessState({required this.searchResult});

  @override
  List<Object?> get props => [searchResult];
}

class ContentSuccess extends BlocState {
  final Page page;

  const ContentSuccess({required this.page});

  @override
  List<Object?> get props => [page];
}

class OfflineState extends BlocState {
  final SearchResult searchResult;

  const OfflineState({required this.searchResult});

  @override
  List<Object?> get props => [searchResult];
}

class ErrorState extends BlocState {
  final String message;

  const ErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
