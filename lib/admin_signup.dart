import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_app/admin_login.dart';

class AdminSignUpScreen extends StatefulWidget {
  const AdminSignUpScreen({super.key});

  @override
  _AdminSignUpScreenState createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  bool _isPasswordVisible = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedBranch;

  final List<String> branches = [
    'Apex College',
    'Herald College',
    'Islington College',
    'Kavya College',
    'KIST College',
    'Kathmandu Engineering College',
    'Texas College',
    'Trinity College'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[500],
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
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Admin Sign Up',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedBranch,
                            items: branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Text(branch),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBranch = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Select Branch',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _fullNameController,
                            hintText: 'Full Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _contactController,
                            hintText: 'Contact',
                            icon: Icons.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: const Text('Sign Up',
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
                                        const AdminLoginScreen()),
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

  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/admin_signup.php'),
        body: {
          'branch_name': _selectedBranch,
          'full_name': _fullNameController.text,
          'contact': _contactController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': 'admin',
        },
      );
      print('Raw Response: ${response.body}');
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Sign up successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error: Network error or invalid response.")),
      );
    }
  }
}