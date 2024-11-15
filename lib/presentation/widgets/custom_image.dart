import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.color,
    this.isFile = false,
  });

  final String path;
  final BoxFit fit;
  final double? height, width;
  final Color? color;
  final bool isFile;

  @override
  Widget build(BuildContext context) {
    if (isFile) {
      return Image.file(
        File(path),
        fit: fit,
        color: color,
        height: height,
        width: width,
      );
    }

    if (path.endsWith('.svg')) {
      if (path.startsWith('http') || path.startsWith('https')) {
        return SvgPicture.network(
          path,
          fit: fit,
          height: height,
          width: width,
          color: color,
          placeholderBuilder: (context) =>
              const Center(child: Icon(Icons.error)),
        );
      } else {
        return SvgPicture.asset(
          path,
          fit: fit,
          height: height,
          width: width,
          color: color,
          placeholderBuilder: (context) =>
              const Center(child: Icon(Icons.error)),
        );
      }
    }
    if (path.startsWith('http') ||
        path.startsWith('https') ||
        path.startsWith('www.')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        color: color,
        height: height,
        width: width,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          );
        },
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    return Image.asset(
      path,
      fit: fit,
      color: color,
      height: height,
      width: width,
    );
  }
}
