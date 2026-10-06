import 'dart:typed_data';

import 'package:portfolio/src/utils/app_images.dart';

import '../repository/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepository();

  static final Map<String, Future<List<Uint8List>>> _imageCache = {};

  Future<Map<String, dynamic>> fetchInfo() {
    return _repository.getInfo();
  }

  Future<List<Uint8List>> fetchImages(String name) {
    return _imageCache.putIfAbsent(name, () async {
      try {
        final base64Images = await _repository.getImages(name);
        return await decodeBase64Images(base64Images);
      } catch (_) {
        // Sem isso uma falha ficaria em cache e "tentar de novo" não faria nada.
        _imageCache.remove(name);
        rethrow;
      }
    });
  }
}
