import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

List<Uint8List> decodeBase64List(List<String> encoded) {
  return encoded.map(base64Decode).toList();
}

Future<List<Uint8List>> decodeBase64Images(List<String> encoded) async {
  if (encoded.isEmpty) {
    return const [];
  }
  if (kIsWeb || encoded.length == 1) {
    return decodeBase64List(encoded);
  }
  return compute(decodeBase64List, encoded);
}

class AppMemoryImage extends StatelessWidget {
  final Uint8List bytes;
  final double width;
  final double? height;
  final BoxFit fit;

  const AppMemoryImage({
    super.key,
    required this.bytes,
    required this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final pixelWidth =
        (width * MediaQuery.devicePixelRatioOf(context)).round();

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      cacheWidth: pixelWidth > 0 ? pixelWidth : null,
    );
  }
}
