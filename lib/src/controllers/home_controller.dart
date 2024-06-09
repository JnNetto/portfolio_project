import '../repository/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepository();

  Future<Map<String, dynamic>> fetchInfo() async {
    try {
      return await _repository.getInfo();
    } catch (e) {
      throw Exception('Error fetching initial info: $e');
    }
  }
}
