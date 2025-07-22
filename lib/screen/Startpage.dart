import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iotcw06/screen/login.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

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
        child: Stack(
          children: [
            // Minimalist food icons in the background
            Positioned(
                top: 100,
                left: 30,
                child: _buildFoodIcon(Icons.restaurant, 50)),
            Positioned(
                top: 200,
                right: 40,
                child: _buildFoodIcon(Icons.local_pizza, 40)),
            Positioned(
                bottom: 150,
                left: 50,
                child: _buildFoodIcon(Icons.icecream, 45)),
            Positioned(
                bottom: 250, right: 60, child: _buildFoodIcon(Icons.cake, 55)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Smart Meal',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Box',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFA000),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Track your nutrition effortlessly',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildStartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodIcon(IconData icon, double size) {
    return Icon(
      icon,
      size: size,
      color: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LoginPage())),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'Get Started',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
