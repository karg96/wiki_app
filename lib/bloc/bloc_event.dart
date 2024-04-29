import 'package:equatable/equatable.dart';

class BlocEvent extends Equatable {
  const BlocEvent();

  @override
  List<Object?> get props => [];
}

class SearchEvent extends BlocEvent {
  final String query;

  const SearchEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class GetContent extends BlocEvent {
  final String title;

  const GetContent({required this.title});

  @override
  List<Object?> get props => [title];
}

class CheckConnectivity extends BlocEvent {}
