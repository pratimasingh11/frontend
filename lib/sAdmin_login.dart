import 'package:flutter/material.dart';
import 'sAdmin_dashboard.dart';
import 'sAdmin_signup.dart'; // Ensure the correct file is imported
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.yellow[300]!;
    final Path path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class sadmin_LoginScreen extends StatefulWidget {
  const sadmin_LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<sadmin_LoginScreen> {
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
      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/sAdmin_login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success']) {
          final userRole = responseData['user']['role'];

          if (userRole == 'superadmin') {
            // Navigate to the admin dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperAdminDashboard(),
              ),
            );
          } else {
            _showError('Access denied: You are not a superadmin');
          }
        } else {
          _showError(responseData['message']);
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred while processing your request');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
    print("Error: $message"); // Log error for debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 183, 16),
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
                        image: AssetImage('assets/signup.jpg'),
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
                          const SizedBox(height: 20),
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
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 40),
                          // Centered Login Button
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: const Text(
                              'Log In',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),),
                          ),
                          const SizedBox(height: 20),
                          // Centered "Don't have an account?" text
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const sadmin_SignUpScreen()),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(color: Colors.black),
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

  Widget _buildTextField(
      {TextEditingController? controller,
      String? hintText,
      IconData? icon,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}