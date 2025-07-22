import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/history_service.dart'; // Import HistoryService

class SetGoalPage extends StatefulWidget {
  const SetGoalPage({super.key});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  double _proteinValue = 50.0;
  double _fatsValue = 35.0;
  double _carbsValue = 45.0;
  bool _isLoading = true;
  final int _selectedIndex = 2;

  // State for daily progress
  Map<String, double>? _todaysNutrition;
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadGoals(),
      _loadTodaysNutrition(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadGoals() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc('userGoals');
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _proteinValue = (data['protein'] as num).toDouble();
          _fatsValue = (data['fats'] as num).toDouble();
          _carbsValue = (data['carbs'] as num).toDouble();
        });
      }
    } catch (e) {
      print("Error loading goals: $e");
    }
  }

  Future<void> _loadTodaysNutrition() async {
    try {
      final nutrition = await _historyService.getTodaysNutrition();
      setState(() {
        _todaysNutrition = nutrition;
      });
    } catch (e) {
      print("Error loading today's nutrition: $e");
    }
  }

  Future<void> _saveGoals() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You must be logged in to save goals.')));
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc('userGoals');
      final totalCalories =
          (_proteinValue * 4) + (_carbsValue * 4) + (_fatsValue * 9);
      await docRef.set({
        'protein': _proteinValue,
        'fats': _fatsValue,
        'carbs': _carbsValue,
        'calories': totalCalories.toInt(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Goals saved successfully!'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save goals.'), backgroundColor: Colors.red));
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) Navigator.pop(context);
    // Add navigation for other items if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9C4), Color(0xFFFFECB3)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFA000)))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            Text('Set your Goals',
                                style: GoogleFonts.poppins(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 40),
                            _buildCalorieDisplay(),
                            const SizedBox(height: 30),
                            _buildGoalSlider(
                                label: 'Protein',
                                value: _proteinValue,
                                max: 4000,
                                onChanged: (v) =>
                                    setState(() => _proteinValue = v)),
                            _buildGoalSlider(
                                label: 'Fats',
                                value: _fatsValue,
                                max: 3000,
                                onChanged: (v) =>
                                    setState(() => _fatsValue = v)),
                            _buildGoalSlider(
                                label: 'Carbs',
                                value: _carbsValue,
                                max: 2000,
                                onChanged: (v) =>
                                    setState(() => _carbsValue = v)),
                            const SizedBox(height: 40),
                            Center(
                                child: SizedBox(
                                    width: 220,
                                    height: 55,
                                    child: ElevatedButton(
                                        onPressed: _saveGoals,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30))),
                                        child: Text('Save',
                                            style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white))))),
                            const SizedBox(height: 40),
                            const Divider(),
                            const SizedBox(height: 20),
                            _buildDailyProgressSection(), // New Section
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomNavBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildDailyProgressSection() {
    if (_todaysNutrition == null) {
      return const Center(child: Text("Could not load today's progress."));
    }

    final totalCaloriesGoal =
        (_proteinValue * 4) + (_carbsValue * 4) + (_fatsValue * 9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Progress',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 20),
        _buildProgressIndicator(
            "Calories", _todaysNutrition!['calories']!, totalCaloriesGoal),
        _buildProgressIndicator(
            "Protein", _todaysNutrition!['protein']!, _proteinValue),
        _buildProgressIndicator(
            "Carbs", _todaysNutrition!['carbs']!, _carbsValue),
        _buildProgressIndicator("Fats", _todaysNutrition!['fats']!, _fatsValue),
        const SizedBox(height: 20),
        _buildSuggestionCard(),
      ],
    );
  }

  Widget _buildProgressIndicator(
      String nutrient, double consumed, double goal) {
    double percent = goal > 0 ? (consumed / goal) : 0;
    Color progressColor = percent > 1.0 ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nutrient,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('${consumed.toInt()} / ${goal.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[300],
            color: progressColor,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    String message = "You're on the right track! Keep it up.";
    IconData icon = Icons.check_circle_outline;
    Color color = Colors.green;

    final totalCaloriesGoal =
        (_proteinValue * 4) + (_carbsValue * 4) + (_fatsValue * 9);
    final caloriesConsumed = _todaysNutrition!['calories']!;

    if (caloriesConsumed > totalCaloriesGoal) {
      message =
          "You've exceeded your calorie goal. Consider a lighter meal next.";
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (caloriesConsumed < totalCaloriesGoal / 2) {
      message =
          "You're doing great! Remember to eat enough to meet your goals.";
      icon = Icons.lightbulb_outline;
      color = Colors.blue;
    }

    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Expanded(
                child: Text(message,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieDisplay() {
    final totalCalories =
        (_proteinValue * 4) + (_carbsValue * 4) + (_fatsValue * 9);
    return Row(
      children: [
        Text('Total Calories:',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(width: 20),
        Text('${totalCalories.toInt()} kcal',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFA000))),
      ],
    );
  }

  Widget _buildGoalSlider(
      {required String label,
      required double value,
      required double max,
      required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            Text('${value.toInt()}g',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFA000))),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFFA000),
            inactiveTrackColor: const Color(0xFFFFE082),
            thumbColor: const Color(0xFFFFA000),
          ),
          child: Slider(value: value, min: 0, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.history_rounded, 1),
          _buildNavItem(Icons.settings_rounded, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon,
          color: isSelected ? const Color(0xFFFFA000) : Colors.grey[600],
          size: 30),
      onPressed: () => _onItemTapped(index),
    );
  }
}
