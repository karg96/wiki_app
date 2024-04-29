import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core_ui/cache_network_image_with_placeholder.dart';
import '../data/model/search_result.dart' as search_result;

class WebPage extends StatelessWidget {
  final search_result.Page page;
  final WebViewController webViewController;

  const WebPage(
      {super.key, required this.page, required this.webViewController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(page.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              page.terms?.description[0] ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: _placeImage(),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(child: WebViewWidget(controller: webViewController)),
          ],
        ),
      ),
    );
  }

  StatelessWidget _placeImage() {
    return CachedNetworkImageWithPlaceholder(
      imageUrl: page.thumbnail?.source ?? "",
      height: page.thumbnail?.height.toDouble(),
      width: page.thumbnail?.width.toDouble(),
    );
  }
}
