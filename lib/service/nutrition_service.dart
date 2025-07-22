import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NutritionService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  final String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
  final Duration _timeoutDuration =
      const Duration(seconds: 30); // Timeout duration

  Future<Map<String, dynamic>> analyzeMeal(
    List<Map<String, dynamic>> mealItems,
  ) async {
    if (_apiKey == null || _apiKey == "YOUR_GEMINI_API_KEY_HERE") {
      throw Exception("API Key not found. Please add it to your .env file.");
    }

    final foodListString = mealItems
        .map((item) => "${item['weight']} of ${item['name']}")
        .join(', ');

    final prompt = """
    You are a nutrition analysis expert. Analyze the following list of food items and their weights.
    For each item, provide the estimated total calories (kcal), carbohydrates (g), protein (g), and fats (g).

    Food list: $foodListString

    Return the result ONLY as a valid JSON object with a single key "ingredients". 
    "ingredients" should be an array of objects. Each object must have these exact keys: 
    "food_name" (string), "calories" (number), "carbs_g" (number), "protein_g" (number), "fats_g" (number).
    Do not include markdown formatting like ```json.
    """;

    // Create an HTTP client with timeout
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse("$_url?key=$_apiKey"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(_timeoutDuration); // Add timeout here

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final jsonString =
            responseBody['candidates'][0]['content']['parts'][0]['text'];

        final nutritionalData = jsonDecode(jsonString);
        return _calculateTotals(nutritionalData);
      } else {
        throw Exception('Failed to get nutritional data: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException {
      throw Exception('Request timed out after $_timeoutDuration');
    } catch (e) {
      throw Exception('Error analyzing meal: $e');
    } finally {
      client.close(); // Always close the client
    }
  }

  Map<String, dynamic> _calculateTotals(Map<String, dynamic> nutritionalData) {
    double totalCalories = 0.0;
    double totalCarbs = 0.0;
    double totalProtein = 0.0;
    double totalFats = 0.0;

    List ingredients = nutritionalData['ingredients'];

    for (var item in ingredients) {
      totalCalories += (item['calories'] as num?) ?? 0;
      totalCarbs += (item['carbs_g'] as num?) ?? 0;
      totalProtein += (item['protein_g'] as num?) ?? 0;
      totalFats += (item['fats_g'] as num?) ?? 0;
    }

    return {
      'calories': totalCalories,
      'carbs': totalCarbs,
      'protein': totalProtein,
      'fats': totalFats,
      'breakdown': ingredients,
    };
  }
}
