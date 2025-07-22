import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'home.dart'; // For navigation after successful sign-up

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        weight: _weightController.text.trim(),
        height: _heightController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst("Exception: ", ""));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst("Exception: ", ""));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Up Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
    _passwordController.clear();
    _rePasswordController.clear();
    _weightController.clear();
    _heightController.clear();
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
        child: Stack(
          children: [
            // Decorative background icons
            Positioned(
                top: 80, left: 30, child: _buildFoodIcon(Icons.restaurant, 50)),
            Positioned(
                top: 180,
                right: 40,
                child: _buildFoodIcon(Icons.local_pizza, 40)),
            Positioned(
                bottom: 150,
                left: 50,
                child: _buildFoodIcon(Icons.icecream, 45)),
            Positioned(
                bottom: 250, right: 60, child: _buildFoodIcon(Icons.cake, 55)),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const SizedBox(height: 20),
                        Text('Sign Up',
                            style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Account',
                            style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFA000))),
                        const SizedBox(height: 30),

                        // Form Fields
                        _buildTextField(
                            controller: _nameController,
                            hintText: 'Enter Your Name',
                            icon: Icons.person,
                            validator: (v) =>
                                v!.isEmpty ? 'Name is required' : null),
                        _buildTextField(
                            controller: _emailController,
                            hintText: 'Enter Your Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty
                                ? 'Email is required'
                                : (!v.contains('@')
                                    ? 'Enter a valid email'
                                    : null)),
                        _buildTextField(
                            controller: _ageController,
                            hintText: 'Enter Your Age',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty
                                ? 'Age is required'
                                : (int.tryParse(v) == null
                                    ? 'Enter a valid number'
                                    : null)),
                        _buildPasswordTextField(
                            controller: _passwordController,
                            hintText: 'Enter Your Password',
                            isFirst: true,
                            validator: (v) => v!.isEmpty
                                ? 'Password is required'
                                : (v.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null)),
                        _buildPasswordTextField(
                            controller: _rePasswordController,
                            hintText: 'Confirm Your Password',
                            isFirst: false,
                            validator: (v) => v != _passwordController.text
                                ? 'Passwords do not match'
                                : null),
                        _buildTextField(
                            controller: _weightController,
                            hintText: 'Enter Your Weight (kg)',
                            icon: Icons.monitor_weight,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty
                                ? 'Weight is required'
                                : (double.tryParse(v) == null
                                    ? 'Enter a valid number'
                                    : null)),
                        _buildTextField(
                            controller: _heightController,
                            hintText: 'Enter Your Height (cm)',
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty
                                ? 'Height is required'
                                : (double.tryParse(v) == null
                                    ? 'Enter a valid number'
                                    : null)),

                        const SizedBox(height: 30),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                        _buildGoogleSignUp(),
                        const SizedBox(height: 20),
                        _buildLoginText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          errorStyle: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
      {required TextEditingController controller,
      required String hintText,
      required bool isFirst,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isFirst ? _obscurePassword : _obscureRePassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          suffixIcon: IconButton(
            icon: Icon(
              (isFirst ? _obscurePassword : _obscureRePassword)
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (isFirst) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureRePassword = !_obscureRePassword;
                }
              });
            },
          ),
          errorStyle: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.black.withOpacity(0.2))),
              elevation: 0,
            ),
            child: Text('Clear',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Submit',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUp() {
    return Column(
      children: [
        Text('or sign up with',
            style: GoogleFonts.poppins(color: Colors.black54)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isLoading ? null : _signUpWithGoogle,
          child: Image.asset('lib/icons/googel.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                  backgroundColor: Colors.white, child: Text('G'))),
        ),
      ],
    );
  }

  Widget _buildLoginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ", style: GoogleFonts.poppins()),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text("Login",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: const Color(0xFFFFA000))),
        ),
      ],
    );
  }

  Widget _buildFoodIcon(IconData icon, double size) {
    return Icon(icon, size: size, color: Colors.black.withOpacity(0.1));
  }
}
