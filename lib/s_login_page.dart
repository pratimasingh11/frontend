import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SDashboard.dart'; // Import the dashboard page

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
        MaterialPageRoute(builder: (context) => SellersDashboard()),
      );
    } else {
      _showError(data['message']);
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
    final response = await http.get(
      Uri.parse('http://localhost/minoriiproject/check_session.php'),
      headers: {"Authorization": sessionId},
    );

    final responseData = json.decode(response.body);

    if (responseData['success']) {
      String sessionId = responseData['session_id']; 
      String email = responseData['user']['email']; // ✅ Corrected
      int branchId = responseData['user']['branch_id'];  // ✅ Corrected

      await prefs.setString('session_id', sessionId);
      await prefs.setString('user_email', email);
      await prefs.setInt('branch_id', branchId);

     Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => SellersDashboard()),
);

    } else {
      _showError("Session expired, please log in again.");
    }
  }
}
Future<void> _handleLogin(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://localhost/minoriiproject/s_login.php'),
    body: jsonEncode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', data['session_id']);
      await prefs.setInt('branch_id', data['branch_id']);  // ✅ Store branch_id
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellersDashboard()));
    } else {
      print("Login failed: ${data['message']}");
    }
  } else {
    print("Server error: ${response.statusCode}");
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
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 200),
              painter: CurvedPainter(),
            ),
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
