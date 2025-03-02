import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  static void preloadImage(BuildContext context, String imageUrl) {
    precacheImage(CachedNetworkImageProvider(imageUrl), context);
  }

  static void preloadImages(BuildContext context, List<String> imageUrls) {
    for (String url in imageUrls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }
}