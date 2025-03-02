import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullSize extends StatefulWidget {
  final String primaryUrl;
  final String fallbackUrl;

  const FullSize({super.key, required this.primaryUrl, required this.fallbackUrl});

  @override
  State<FullSize> createState() => _FullSizeState();
}

class _FullSizeState extends State<FullSize> {
  late ValueNotifier<String> imageUrlNotifier;

  @override
  void initState() {
    super.initState();
    imageUrlNotifier = ValueNotifier(widget.primaryUrl);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    imageUrlNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: imageUrlNotifier,
      builder: (context, imageUrl, child) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) {
            if (imageUrl == widget.primaryUrl) {
              // 첫 번째 URL이 실패하면 두 번째 URL로 변경
              imageUrlNotifier.value = widget.fallbackUrl;
              return const SizedBox(); // 빈 공간 반환 (UI 깜빡임 방지)
            }
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      },
    );
  }
}
