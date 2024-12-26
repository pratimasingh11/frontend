import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'account_page.dart';
import 'inventory_page.dart';
import 'cart_page.dart';

void main() {
  runApp(MyApp(initialPage:InventoryPage())); // Change this to the desired page
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