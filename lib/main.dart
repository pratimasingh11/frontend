import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart'; // Import the CartProvider
import 'cart_page.dart';
import 'welcome_page.dart';
import 'category_page.dart';
import 'indian_menu_page.dart';
import 'Nepali_menu_page.dart';
import 'Italian_page.dart';
import 'Chinese_menu_page.dart';
import 'soft drinks.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'checkout_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // Provide CartProvider
      child: const EazyMealsApp(),
    ),
  );
}

class EazyMealsApp extends StatelessWidget {
  const EazyMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Meals',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/home_page',
      routes: {
        '/home_page': (context) => const HomePage(),
        // '/s_signup_page': (context) => const s_SignUpScreen(),
        // '/s_login_page': (context) => const s_LoginScreen(),
        // '/sproduct_page': (context) => const ProductsPage(),
        // '/SDashboard': (context) => const SellersDashboard(),
        '/signup_page': (context) => const SignUpScreen(),
        '/login_page': (context) => const LoginScreen(),
        '/welcome_page': (context) => const WelcomePage(),
        '/category_page': (context) => const CategoryPage(),
        '/indian_menu_page': (context) => const IndianMenuPage(),
        '/Nepali_menu_page': (context) => const NepaliMenuPage(),
        '/italian_page': (context) => const ItalianMenuPage(),
        '/chinese_menu_page': (context) => const ChineseMenuPage(),
        '/soft drinks': (context) => const SoftDrinksMenuPage(),
        '/checkout_page': (context) => const CheckoutPage(),
        '/cart_page': (context) => const CartPage(),
      },
    );
  }
}
