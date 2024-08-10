import 'dart:convert';
import 'dart:typed_data';

import '../repository/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepository();

  Future<Map<String, dynamic>> fetchInfo() async {
    try {
      final data = await _repository.getInfo();

      if (data.containsKey("attributes") && data["attributes"] is List) {
        for (var attribute in data["attributes"]) {
          if (attribute is Map && attribute.containsKey("image")) {
            attribute["image"] = base64Decode(attribute["image"]);
          }
        }
      }

      return data;
    } catch (e) {
      throw Exception('Error fetching initial info: $e');
    }
  }

  Future<List<Uint8List>> fetchImages(String name) async {
    try {
      // Obtém a lista de strings base64
      List<String> base64Images = await _repository.getImages(name);

      // Converte cada string base64 em um Uint8List
      List<Uint8List> images = base64Images.map((base64String) {
        return base64Decode(base64String);
      }).toList();

      return images;
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}
