import 'package:firebase_database/firebase_database.dart';

class HomeRepository {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> getInfo() async {
    DatabaseEvent snapshot =
        (await _databaseReference.child('initial_info').once());
    return Map<String, dynamic>.from(snapshot.snapshot.value as Map);
  }
}
