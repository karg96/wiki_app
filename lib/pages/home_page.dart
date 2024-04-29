import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wiki_app/bloc/bloc_event.dart';
import 'package:wiki_app/bloc/bloc_state.dart';
import 'package:wiki_app/bloc/wikipedia_bloc.dart';
import 'package:wiki_app/data/model/search_result.dart' as result;
import 'package:wiki_app/pages/web_page.dart';

import '../core_ui/cache_network_image_with_placeholder.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  late WebViewController _webViewController = WebViewController();

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
            _iniWebView(state);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebPage(
                        page: state.page,
                        webViewController: _webViewController))).then((value) =>
                context.read<WikipediaBloc>().add(CheckConnectivity()));
          }
        },
        child: BlocBuilder<WikipediaBloc, BlocState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _searchBar(context, state),
                    const SizedBox(height: 16),
                    if (state is LoadingState) ...[
                      const Center(
                          child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator()))
                    ] else if (state is QuerySuccessState ||
                        state is OfflineState) ...[
                      Expanded(
                        child: ListView.builder(
                            itemCount: (state as dynamic)
                                    .searchResult
                                    .query
                                    ?.pages
                                    ?.length ??
                                0,
                            itemBuilder: (context, index) {
                              final item = (state as dynamic)
                                  .searchResult
                                  .query
                                  ?.pages?[index];
                              return _searchResultItem(item, context);
                            }),
                      )
                    ] else if (state is ErrorState) ...[
                      Center(child: Text(state.message))
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Card _searchResultItem(result.Page? item, BuildContext context) {
    return Card(
      child: ListTile(
        key: Key(item?.pageId.toString() ?? ''),
        leading: SizedBox(width: 50, height: 50, child: _placeImage(item)),
        // Use a placeholder if thumbnail is null
        title: Text(item?.title ?? "Not found"),
        subtitle: Text(item?.terms?.description[0] ?? 'No description found'),
        onTap: () {
          context
              .read<WikipediaBloc>()
              .add(GetContent(title: item?.title ?? ''));
        },
      ),
    );
  }

  StatelessWidget _placeImage(result.Page? item) {
    return CachedNetworkImageWithPlaceholder(
      imageUrl: item?.thumbnail?.source ?? "",
      height: item?.thumbnail?.height.toDouble(),
      width: item?.thumbnail?.width.toDouble(),
    );
  }

  Container _searchBar(BuildContext context, BlocState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: state is OfflineState
          ? ElevatedButton(
              onPressed: () {
                context.read<WikipediaBloc>().add(CheckConnectivity());
              },
              child: const Text('You are offline, click to refresh'),
            )
          : TextField(
              decoration: const InputDecoration(
                hintText: 'Search Wikipedia',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (query) {
                if (query.length >= 2) {
                  context.read<WikipediaBloc>().add(SearchEvent(query: query));
                }
              },
            ),
    );
  }

  void _iniWebView(ContentSuccess state) {
    _webViewController = WebViewController()
      ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString("""
      <!DOCTYPE html>
        <html>
          <head><meta name="viewport" content="width=device-width, initial-scale=0.7"></head>
          <body style='"margin: 0; padding: 0;'>
            ${state.page.extract}
              </body>
            </html>
          """);
  }
}
