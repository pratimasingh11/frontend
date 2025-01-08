import 'package:flutter/material.dart';
import 's_login_page.dart'; 
import 's_signup_page.dart'; 
import 'SDashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Meals',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/s_signup_page',  // Start with the signup page
      routes: {
        '/s_signup_page': (context) => s_SignUpScreen(),
        '/s_login_page': (context) => s_LoginScreen (),  // Add other routes here
       // '/SDashboard': (context) => SellersDashboard (),
      },
    );
  }
}

