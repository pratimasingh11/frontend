import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_page.dart'; // Import the dashboard page
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      Uri.parse('http://10.0.2.2/minoriiproject/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Login Response: $data");

      if (data['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', data['session_id'] ?? '');
        await prefs.setInt('branch_id', data['user']['branch_id'] ?? 0);
        await prefs.setInt('user_id', data['user']['id'] ?? 0);

        print("User Login Success - Redirecting to WelcomePage");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      } else {
        _showError(data['message'] ?? 'Login failed');
      }
    } else {
      _showError('Server error: ${response.statusCode}');
    }
  } catch (e) {
    print("Error: $e");
    _showError('An error occurred while processing your request');
  }
}

Future<void> _checkSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sessionId = prefs.getString('session_id');

  if (sessionId != null) {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/minoriiproject/check_session.php'),
        headers: {"Authorization": sessionId},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Session Check Response: $responseData");

        if (responseData['success']) {
          await prefs.setString('session_id', responseData['session_id'] ?? '');
          await prefs.setString('user_email', responseData['user']['email'] ?? '');
          await prefs.setInt('branch_id', responseData['user']['branch_id'] ?? 0);
          await prefs.setInt('user_id', responseData['user']['id'] ?? 0);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
        } else {
          _showError("Session expired, please log in again.");
        }
      }
    } catch (e) {
      print("Session Check Error: $e");
      _showError('An error occurred while checking session');
    }
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
      backgroundColor: Colors.yellow[50],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/login1.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            hintText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 244, 203, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
