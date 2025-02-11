import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_app/sAdmin_login.dart';

class sadmin_SignUpScreen extends StatefulWidget {
  const sadmin_SignUpScreen({super.key});

  @override
  s_SignUpScreenState createState() => s_SignUpScreenState();
}

class s_SignUpScreenState extends State<sadmin_SignUpScreen> {
  bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
                              'Sign Up',
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
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm your password',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 40),
                          // Centered SignUp Button
                          ElevatedButton(
                            onPressed: () async {
                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Passwords do not match!"),
                                  ),
                                );
                                return;
                              }

                              try {
                                final response = await http.post(
                                  Uri.parse(
                                      'http://localhost/minoriiproject/sAdmin_signup.php'),
                                  body: {
                                    'email': _emailController.text,
                                    'password': _passwordController.text,
                                  },
                                );

                                final data = json.decode(response.body);

                                if (data['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(data['message'] ??
                                          'Sign up successful!'),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const sadmin_LoginScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(data['message'] ??
                                          'An error occurred.'),
                                    ),
                                  );
                                }
                              } catch (e) {ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Error: Network error or invalid response."),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: const Text(
                              'Sign Up',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Centered "Already have an account?" text
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const sadmin_LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Already have an account? Log in",
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