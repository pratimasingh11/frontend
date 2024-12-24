import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'checkout_page.dart';
import 'scategories_page.dart';
import 'sproduct_page.dart';

void main() {
  runApp(MyApp(initialPage: LoginScreen())); // Change this to the desired page
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  MyApp({required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: initialPage, // Set the initial page dynamically
    );
  }
}