import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/constraints.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.color,
    this.isFile = false,
    this.errorPath,
  });

  final String? path;
  final String? errorPath;
  final BoxFit fit;
  final double? height, width;
  final Color? color;
  final bool isFile;

  @override
  Widget build(BuildContext context) {
    const kNetImg = 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
    final imagePath = path ?? kNetImg;

    if (isFile) {
      return Image.file(
        File(imagePath),
        fit: fit,
        color: color,
        height: height,
        width: width,
      );
    }

    if (path?.endsWith('.svg')??false) {
      if ((path?.startsWith('http')??false) || (path?.startsWith('https')??false)) {
        //debugPrint('this is svg network');
        return SvgPicture.network(
          imagePath,
          fit: fit,
          height: height,
          width: width,
          color: color,
          placeholderBuilder: (context) =>
          const Center(child: Icon(Icons.error)),
        );
      } else {
        //debugPrint('this is not svg network');
        return SvgPicture.asset(
          imagePath,
          fit: fit,
          height: height,
          width: width,
          color: color,
          placeholderBuilder: (context) =>
          const Center(child: Icon(Icons.error)),
        );
      }
    }
    if (imagePath.startsWith('http') ||
        imagePath.startsWith('https') ||
        imagePath.startsWith('www.')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        color: color,
        height: height,
        width: width,
        // errorListener: (Object obj){
        //   if (obj.toString().contains('HTTP request failed, statusCode: 404')){
        //   debugPrint('40444444444444');
        //   }
        //   debugPrint('new-error-occurred ${obj.toString()}');
        // },

        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Shimmer.fromColors(
            baseColor: whiteColor,
            highlightColor: Colors.grey.shade100,
            // baseColor: greenColor,
            // highlightColor: redColor,
            child: Container(
              height: height ?? 100,
              width: width ?? 100,
              color: whiteColor,
            ),
          );
        },
        errorWidget: (context, url, error) {
          if (error.toString().contains('Invalid image data')) {
            return Image.network(
              Uri.encodeFull(kNetImg),
              fit: fit,
              color: color,
              height: height,
              width: width,
            );
          }else if (error is HttpException || error is Exception) {
            return Image.network(
              Uri.encodeFull(errorPath ?? kNetImg),
              fit: fit,
              color: color,
              height: height,
              width: width,
            );
          } else if (error.toString().contains('Invalid statusCode: 404')){
            return Image.network(
              Uri.encodeFull(kNetImg),
              fit: fit,
              color: color,
              height: height,
              width: width,
            );
          }else if (error.toString().contains('HTTP request failed, statusCode: 404')){
            return Image.network(
              Uri.encodeFull(kNetImg),
              fit: fit,
              color: color,
              height: height,
              width: width,
            );
          }else{
            return const Icon(Icons.error);
          }
        },
      );
    }
    // if (path?.endsWith('.webp')??false) {
    //   return Image.asset(
    //     Uri.encodeFull(imagePath),
    //     // path??'',
    //     fit: fit,
    //     color: color,
    //     height: height,
    //     width: width,
    //   );
    // }
    return Image.asset(
      imagePath,
      fit: fit,
      color: color,
      height: height,
      width: width,
    );
  }
}