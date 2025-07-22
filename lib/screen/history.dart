import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/meal_history_data.dart';
import '../service/history_service.dart';
import 'setgoal.dart';
import '../helpers/string_extensions.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  int _selectedTimeframe1 = 0;
  int _selectedTimeframe2 = 1;
  int _selectedIndex = 1;

  List<MealHistoryData> _filterByTimeframe(
      List<MealHistoryData> data, int timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case 0:
        return data.where((meal) {
          final mealDate = meal.timestamp.toDate();
          return mealDate.year == now.year &&
              mealDate.month == now.month &&
              mealDate.day == now.day;
        }).toList();
      case 1:
        final weekAgo = now.subtract(const Duration(days: 7));
        return data
            .where((meal) => meal.timestamp.toDate().isAfter(weekAgo))
            .toList();
      case 2:
        final monthAgo = now.subtract(const Duration(days: 30));
        return data
            .where((meal) => meal.timestamp.toDate().isAfter(monthAgo))
            .toList();
      default:
        return data;
    }
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MealHistoryData>>(
                stream: _historyService.mealHistoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFFA000)));
                  }

                  if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final allHistoryData = snapshot.data!;
                  final macroData =
                      _filterByTimeframe(allHistoryData, _selectedTimeframe1);
                  final calorieData =
                      _filterByTimeframe(allHistoryData, _selectedTimeframe2);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildSectionTitle('Macronutrients'),
                        _buildTimeToggle(
                          selectedIndex: _selectedTimeframe1,
                          onSelect: (index) =>
                              setState(() => _selectedTimeframe1 = index),
                        ),
                        const SizedBox(height: 20),
                        _buildMacronutrientsChart(macroData),
                        const SizedBox(height: 40),
                        _buildSectionTitle('Calories'),
                        _buildTimeToggle(
                          selectedIndex: _selectedTimeframe2,
                          onSelect: (index) =>
                              setState(() => _selectedTimeframe2 = index),
                        ),
                        const SizedBox(height: 20),
                        _buildCaloriesChart(calorieData),
                        const SizedBox(height: 40),
                        _buildSectionTitle('Recent Meals'),
                        const SizedBox(height: 10),
                        _buildRecentMealsList(allHistoryData),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Meal History',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black87),
          onPressed: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMacronutrientsChart(List<MealHistoryData> data) {
    if (data.isEmpty) {
      return _buildEmptyDataPlaceholder('No data for this timeframe');
    }

    double totalFats = data.fold(0.0, (sum, item) => sum + item.fats);
    double totalCarbs = data.fold(0.0, (sum, item) => sum + item.carbs);
    double totalProtein = data.fold(0.0, (sum, item) => sum + item.protein);
    double maxY =
        [totalFats, totalCarbs, totalProtein].reduce((a, b) => a > b ? a : b) *
            1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: _chartBoxDecoration(),
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY : 10,
          barGroups: [
            _makeBarGroupData(0, totalFats, const Color(0xFFF25353)),
            _makeBarGroupData(1, totalCarbs, const Color(0xFF4CAF50)),
            _makeBarGroupData(2, totalProtein, const Color(0xFFFFA000)),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 10)))),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const titles = ['Fats', 'Carbs', 'Protein'];
                      return Text(titles[value.toInt()],
                          style: GoogleFonts.poppins(color: Colors.grey));
                    })),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
            toY: y,
            color: color,
            width: 25,
            borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildCaloriesChart(List<MealHistoryData> data) {
    if (data.isEmpty) {
      return _buildEmptyDataPlaceholder('No data for this timeframe');
    }

    final dailyCalories = <DateTime, double>{};
    for (var meal in data) {
      final date = DateTime(meal.timestamp.toDate().year,
          meal.timestamp.toDate().month, meal.timestamp.toDate().day);
      dailyCalories.update(date, (value) => value + meal.calories,
          ifAbsent: () => meal.calories);
    }

    final sortedDates = dailyCalories.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyCalories[entry.value]!);
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: _chartBoxDecoration(),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFFFA000),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: const Color(0xFFFFA000).withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMealsList(List<MealHistoryData> meals) {
    if (meals.isEmpty) return const SizedBox.shrink();

    return Column(
      children: meals
          .take(5)
          .map((meal) => Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(meal.timestamp),
                          style: GoogleFonts.poppins(
                              color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${meal.calories.round()} kcal',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFA000))),
                          Text(meal.mealType.capitalize(),
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal.mealItems.map((item) => item['name']).join(', '),
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTimeToggle(
      {required int selectedIndex, required ValueChanged<int> onSelect}) {
    final options = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFF4A3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    options[index],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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
            spreadRadius: 5,
          ),
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetGoalPage()),
      );
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFFFFA000) : Colors.grey[600],
        size: 30,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  Widget _buildEmptyDataPlaceholder(String message) {
    return Container(
      height: 250,
      decoration: _chartBoxDecoration(),
      child: Center(
          child: Text(message, style: GoogleFonts.poppins(color: Colors.grey))),
    );
  }

  BoxDecoration _chartBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2)
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text('Failed to load history',
                style: GoogleFonts.poppins(fontSize: 18)),
            const SizedBox(height: 10),
            Text(error,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA000)),
              child: Text('Retry',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          Text('No meal history yet', style: GoogleFonts.poppins(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Analyze your first meal to see data here',
              style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA000)),
            child: Text('Refresh',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
