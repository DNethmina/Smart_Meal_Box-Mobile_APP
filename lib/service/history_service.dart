import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_history_data.dart'; // Ensure this path is correct

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Provides a real-time stream of the user's meal history.
  Stream<List<MealHistoryData>> get mealHistoryStream {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error(
          Exception('User not logged in. Cannot fetch history.'));
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final List<MealHistoryData> historyList = [];
      for (final doc in snapshot.docs) {
        try {
          historyList.add(MealHistoryData.fromFirestore(doc));
        } catch (e) {
          print('Could not parse document ${doc.id}: $e');
        }
      }
      return historyList;
    });
  }

  /// Calculates the total nutrition for the current day.
  Future<Map<String, double>> getTodaysNutrition() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    // Get today's date range
    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .get();

    double totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFats = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      totalCalories += (data['calories'] as num?)?.toDouble() ?? 0;
      totalCarbs += (data['carbs'] as num?)?.toDouble() ?? 0;
      totalProtein += (data['protein'] as num?)?.toDouble() ?? 0;
      totalFats += (data['fats'] as num?)?.toDouble() ?? 0;
    }

    return {
      'calories': totalCalories,
      'carbs': totalCarbs,
      'protein': totalProtein,
      'fats': totalFats,
    };
  }

  /// Saves a meal analysis result as a new document in the user's history.
  Future<void> saveMealAnalysis(Map<String, dynamic> analysisData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot save history.');
    }

    if (!analysisData.containsKey('createdAt')) {
      analysisData['createdAt'] = FieldValue.serverTimestamp();
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(analysisData);
    } catch (e) {
      print('Error saving meal analysis: $e');
      throw Exception('Failed to save meal analysis.');
    }
  }
}
