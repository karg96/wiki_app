import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wiki_app/bloc/bloc_event.dart';
import 'package:wiki_app/bloc/bloc_state.dart';
import 'package:wiki_app/bloc/wikipedia_bloc.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikipedia'),
        centerTitle: true,
      ),
      body: BlocListener<WikipediaBloc, BlocState>(
        listener: (context, state) {
          if (state is ContentSuccess) {
            _webViewController = WebViewController()
              ..enableZoom(true)
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString("""
      <!DOCTYPE html>
        <html>
          <head><meta name="viewport" content="width=device-width, initial-scale=0.7"></head>
          <body style='"margin: 0; padding: 0;'>
            ${state.extract}
          </body>
        </html>
      """);
          }
        },
        child: BlocBuilder<WikipediaBloc, BlocState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search Wikipedia',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (query) {
                        if (query.length >= 2) {
                          context
                              .read<WikipediaBloc>()
                              .add(SearchEvent(query: query));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state is LoadingState) ...[
                    const Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator()))
                  ] else if (state is QuerySuccessState) ...[
                    Expanded(
                      child: ListView.builder(
                          itemCount: state.searchResult.query?.pages?.length,
                          itemBuilder: (context, index) {
                            final item =
                                state.searchResult.query?.pages?[index];
                            return Card(
                              child: ListTile(
                                leading: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: item?.thumbnail?.source != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                item?.thumbnail?.source ?? "",
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          )
                                        : const Placeholder()),
                                // Use a placeholder if thumbnail is null
                                title: Text(item?.title ?? "Not found"),
                                subtitle: Text(item?.terms?.description[0] ??
                                    'No description found'),
                                onTap: () {
                                  context.read<WikipediaBloc>().add(
                                      GetContent(title: item?.title ?? ''));
                                },
                              ),
                            );
                          }),
                    )
                  ] else if (state is ContentSuccess) ...[
                    Expanded(
                        child: WebViewWidget(controller: _webViewController))
                  ] else if (state is ErrorState) ...[
                    Center(child: Text(state.message))
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final void Function(String) onSearchTextChanged;

  const SearchBar({Key? key, required this.onSearchTextChanged})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_controller.text.length >= 2) {
      widget.onSearchTextChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Search Wikipedia',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
