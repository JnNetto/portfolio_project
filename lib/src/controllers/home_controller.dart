import '../repository/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepository();

  Future<Map<String, dynamic>> fetchInitialInfo() async {
    try {
      return await _repository.getInitialInfo();
    } catch (e) {
      throw Exception('Error fetching initial info: $e');
    }
  }
}
