import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedNetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;

  const CachedNetworkImageWithPlaceholder({super.key,
    required this.imageUrl,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Placeholder(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}