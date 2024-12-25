import 'package:flutter/material.dart';

import 'welcome_page.dart';
import 'category_page.dart';
// import 'cuisine_menu.dart'; // Import the generic cuisine menu page
import 'SDashboard.dart'; // Import Seller Dashboard
import 'account.dart';
import 'indian_menu_page.dart';

void main() {
  runApp(EazyMealsApp());
}

class EazyMealsApp extends StatelessWidget {
  const EazyMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EazyMeals',
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      routes: {
        '/category': (context) => CategoryPage(),
        // '/cuisineMenu': (context) => CuisineMenu(
        //     cuisineName: 'Indian'), // Route for generic cuisine menu
        '/sellerDashboard': (context) =>
            SellersDashboard(), // Route for seller dashboard
        '/account': (context) => const CakePriceListApp(),
        '/indianMenu': (context) => IndianMenuPage(),
      },
    );
  }
}
