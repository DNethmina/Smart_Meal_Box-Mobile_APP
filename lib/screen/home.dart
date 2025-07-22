import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import '../service/nutrition_service.dart';
import '../service/history_service.dart';
import '../helpers/string_extensions.dart';
import 'history.dart';
import 'profile.dart';
import 'setgoal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final NutritionService _nutritionService = NutritionService();
  final HistoryService _historyService = HistoryService();

  final List<Map<String, dynamic>> _mealItems = List.generate(
    3,
    (index) => {
      'name': '',
      'weight': 0,
      'controller': TextEditingController(),
    },
  );

  String _selectedMealType = 'breakfast';
  bool _isAnalyzing = false;
  int _liveTemp = 0;
  int _liveWeight = 0;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _mealSubscription;
  late StreamSubscription<DatabaseEvent> _tempSubscription;
  late StreamSubscription<DatabaseEvent> _liveWeightSubscription;

  @override
  void initState() {
    super.initState();
    _setupDatabaseListeners();
    _setupMealListener();
  }

  void _setupDatabaseListeners() {
    _tempSubscription = _dbRef.child('live/temp').onValue.listen((event) {
      if (mounted && event.snapshot.exists) {
        setState(
            () => _liveTemp = (event.snapshot.value as num?)?.toInt() ?? 0);
      }
    });

    _liveWeightSubscription =
        _dbRef.child('live/weight').onValue.listen((event) {
      if (mounted && event.snapshot.exists) {
        setState(
            () => _liveWeight = (event.snapshot.value as num?)?.toInt() ?? 0);
      }
    });
  }

  void _setupMealListener() {
    _mealSubscription?.cancel();
    _mealSubscription =
        _dbRef.child('Meal/$_selectedMealType').onValue.listen((event) {
      if (mounted && event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
        setState(() {
          _mealItems[0]['weight'] =
              (data['con1']?['weight'] as num?)?.toInt() ?? 0;
          _mealItems[1]['weight'] =
              (data['con2']?['weight'] as num?)?.toInt() ?? 0;
          _mealItems[2]['weight'] =
              (data['con3']?['weight'] as num?)?.toInt() ?? 0;
        });
      }
    });
  }

  Future<void> _analyzeMeal() async {
    final mealsToAnalyze = <Map<String, dynamic>>[];
    for (int i = 0; i < 3; i++) {
      final name = _mealItems[i]['controller'].text.trim();
      if (name.isNotEmpty && _mealItems[i]['weight'] > 0) {
        mealsToAnalyze.add({
          'name': name,
          'weight': _mealItems[i]['weight'],
        });
      }
    }

    if (mealsToAnalyze.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one meal item with weight')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final analysis = await _nutritionService.analyzeMeal(mealsToAnalyze);
      analysis['mealType'] = _selectedMealType;
      analysis['createdAt'] = FieldValue.serverTimestamp();
      analysis['mealItems'] = mealsToAnalyze;

      await _historyService.saveMealAnalysis(analysis);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_selectedMealType.capitalize()} analyzed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      for (var item in _mealItems) {
        item['controller'].clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  void dispose() {
    for (var item in _mealItems) {
      item['controller'].dispose();
    }
    _mealSubscription?.cancel();
    _tempSubscription.cancel();
    _liveWeightSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              child: Stack(
                children: [
                  // Food icons in the background
                  Positioned(
                    top: 80,
                    left: 30,
                    child: _buildFoodIcon(Icons.restaurant, 50),
                  ),
                  Positioned(
                    top: 180,
                    right: 40,
                    child: _buildFoodIcon(Icons.local_pizza, 40),
                  ),
                  Positioned(
                    bottom: 150,
                    left: 50,
                    child: _buildFoodIcon(Icons.icecream, 45),
                  ),
                  Positioned(
                    bottom: 250,
                    right: 60,
                    child: _buildFoodIcon(Icons.cake, 55),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(),
                            const SizedBox(height: 30),
                            _buildInfoCard(),
                            const SizedBox(height: 30),
                            _buildMealTypeSelector(),
                            const SizedBox(height: 20),
                            _buildMealItemsList(),
                            const SizedBox(height: 30),
                            _buildAnalyzeButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem("$_liveWeight g", "Total Weight"),
          _buildInfoItem("$_liveTemp °C", "Temperature"),
        ],
      ),
    );
  }

  Widget _buildMealItemsList() {
    return Column(
      children: [
        _buildMealItemCard(0, 'Container 1'),
        const SizedBox(height: 15),
        _buildMealItemCard(1, 'Container 2'),
        const SizedBox(height: 15),
        _buildMealItemCard(2, 'Container 3'),
      ],
    );
  }

  Widget _buildMealItemCard(int index, String title) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4A3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_mealItems[index]['weight']} g',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mealItems[index]['controller'],
              decoration: InputDecoration(
                hintText: 'Enter ${title.toLowerCase()} food name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: _selectedMealType,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
        underline: const SizedBox(),
        isExpanded: true,
        items: ['breakfast', 'lunch', 'dinner'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Center(
              child: Text(
                value.capitalize(),
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedMealType = newValue;
              _setupMealListener();
            });
          }
        },
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _isAnalyzing ? null : _analyzeMeal,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: _isAnalyzing
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'Analyze ${_selectedMealType.capitalize()}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Smart Meal Box',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black87),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black87),
              onPressed: () async {
                await _authService.signOut();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.history, 1),
          _buildNavItem(Icons.settings, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? const Color(0xFFFFA000) : Colors.grey[600],
          size: 28,
        ),
        onPressed: () => _onItemTapped(index),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HistoryPage()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SetGoalPage()));
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildInfoItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFoodIcon(IconData icon, double size) {
    return Icon(
      icon,
      size: size,
      color: Colors.black.withOpacity(0.1),
    );
  }
}
