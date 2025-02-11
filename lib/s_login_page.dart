import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SDashboard.dart'; // Import the dashboard page
import 's_signup_page.dart';

class s_LoginScreen extends StatefulWidget {
  const s_LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<s_LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    try {
      final response = await loginUser(email, password);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = json.decode(response.body);

      if (data['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', data['session_id']);
        await prefs.setInt('branch_id', data['user']['branch_id']);

        print("Saved session_id: ${data['session_id']}");
        print("Saved branch_id: ${data['user']['branch_id']}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellersDashboard()),
        );
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      print("Error: $e");
      _showError('An error occurred while processing your request');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 244, 183, 16),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 800,
            height: 550, // You can adjust this height if needed
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Image Section - Taking equal width as the form
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/signup.jpg'), // Update your image path
                        fit: BoxFit.cover, // Ensure the image covers the area
                      ),
                    ),
                  ),
                ),
                // Form Section - Taking equal width as the image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center content vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center content horizontally
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                              child: Image.asset(
                                'assets/logo.png',
                                height: 80,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Center(
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email),
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                   const Color.fromARGB(255, 244, 183, 16),shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: const Text(
                              'Log In',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const s_SignUpScreen()),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(color: Colors.blue),
                            ),
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
}

// ✅ Moved outside the widget class
Future<http.Response> loginUser(String email, String password) async {
  final url = Uri.parse("http://localhost/minoriiproject/s_login.php");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json", // Ensure JSON format
    },
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  return response;
}