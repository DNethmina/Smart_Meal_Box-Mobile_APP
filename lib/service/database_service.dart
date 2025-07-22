import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  // Get a reference to the 'live' node in your Realtime Database
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref(
    'live',
  );

  // Create a stream that listens for changes at the 'live' node.
  // The stream will emit a DatabaseEvent whenever the data changes.
  Stream<DatabaseEvent> get liveDataStream {
    return _databaseReference.onValue;
  }
}
