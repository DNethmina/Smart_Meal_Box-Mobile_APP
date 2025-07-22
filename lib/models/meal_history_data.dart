import 'package:cloud_firestore/cloud_firestore.dart';

class MealHistoryData {
  final String id;
  final double fats;
  final double carbs;
  final double protein;
  final double calories;
  final Timestamp
      timestamp; // Keep 'timestamp' as the model field name for consistency in the app
  final String mealType;
  final List<dynamic> mealItems;

  MealHistoryData({
    required this.id,
    required this.fats,
    required this.carbs,
    required this.protein,
    required this.calories,
    required this.timestamp,
    required this.mealType,
    required this.mealItems,
  });

  /// A robust factory constructor to safely create a MealHistoryData object from a Firestore document.
  factory MealHistoryData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper function to safely parse numbers from any num type (int or double)
    double safeGetDouble(String key) {
      final value = data[key];
      return (value is num) ? value.toDouble() : 0.0;
    }

    return MealHistoryData(
      id: doc.id,
      fats: safeGetDouble('fats'),
      carbs: safeGetDouble('carbs'),
      protein: safeGetDouble('protein'),
      calories: safeGetDouble('calories'),
      // Read from the 'createdAt' field in Firestore, but assign to 'timestamp' in the model
      timestamp: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
      mealType: data['mealType'] as String? ?? 'Unknown',
      mealItems:
          data['mealItems'] is List ? data['mealItems'] as List<dynamic> : [],
    );
  }
}
