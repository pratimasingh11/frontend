import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession(); // Check session on app start
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/admin_login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData'); // Debug API Response

        if (responseData['success']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('session_id', responseData['session_id']);
          await prefs.setInt('admin_id', responseData['user']['id']);
          await prefs.setString('admin_email', responseData['user']['email']);
          await prefs.setInt('branch_id', responseData['user']['branch_id']);
          await prefs.setString(
              'branch_name', responseData['user']['branch_name']);

          // Debugging: Verify Stored Session ID
          String? storedSession = prefs.getString('session_id');
          print("Stored Session ID: $storedSession");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          _showError(responseData['message']);
        }
      } else {
        _showError('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
      print("Error: $e");
    }
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionId = prefs.getString('session_id');

    if (sessionId == null || sessionId.isEmpty) {
      return; // No session found, stay on login screen
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost/minoriiproject/check_session1.php'),
        headers: {'Authorization': sessionId},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Session Check Response: $responseData');

        if (responseData['success']) {
          await prefs.setString('session_id', responseData['session_id']);
          await prefs.setString('admin_email', responseData['user']['email']);
          await prefs.setInt('branch_id', responseData['user']['branch_id']);
          await prefs.setInt('admin_id', responseData['user']['id']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        }
      }
    } catch (e) {
      print("Session Check Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[500],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 800,
            height: 550,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, spreadRadius: 2)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      image: DecorationImage(
                          image: AssetImage('assets/signup.jpg'),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset('assets/logo.png', height: 80),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text('Log In',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              icon: Icons.email),
                          const SizedBox(height: 20),
                          _buildTextField(
                              controller: _passwordController,
                              hintText: 'Enter your password',
                              icon: Icons.lock,
                              isPassword: true),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: const Text('Log In',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminSignUpScreen()));
                            },
                            child: const Text("Don't have an account? Sign up",
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}