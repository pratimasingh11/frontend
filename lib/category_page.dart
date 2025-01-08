import 'package:flutter/material.dart';
import 'Nepali_menu_page.dart'; // Import NepaliMenuPage
import 'indian_menu_page.dart';
import 'chinese_menu_page.dart';
import 'italian_page.dart';
import 'soft drinks.dart';
import 'sweets.dart';

class CategoryPage extends StatelessWidget {
  final List<Map<String, String>> cuisines = const [
    {'name': 'Indian', 'image': 'assets/indian.jpg'},
    {'name': 'Nepali', 'image': 'assets/nepalese.jpg'},
    {'name': 'Italian', 'image': 'assets/italian.jpg'},
    {'name': 'Chinese', 'image': 'assets/chinese.jpg'},
    {'name': 'Soft Drinks', 'image': 'assets/cold_drinks.jpg'},
    {'name': 'Sweets', 'image': 'assets/sweet.jpg'},
  ];

  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuisines'),
        backgroundColor: const Color(0xFFFFC400),
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: cuisines.length,
          itemBuilder: (context, index) {
            final cuisineName = cuisines[index]['name'] ?? 'Unknown Cuisine';
            final cuisineImage =
                cuisines[index]['image'] ?? 'assets/default.jpg';

            return GestureDetector(
              onTap: () {
                // Check for Nepali cuisine and navigate accordingly
                if (cuisineName == 'Nepali') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NepaliMenuPage(),
                    ),
                  );
                } else if (cuisineName == 'Indian') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndianMenuPage(),
                    ),
                  );
                } else if (cuisineName == 'Italian') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItalianMenuPage(),
                    ),
                  );
                } else if (cuisineName == 'Chinese') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChineseMenuPage(),
                    ),
                  );
                } else if (cuisineName == 'Soft Drinks') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SoftDrinksMenuPage(),
                    ),
                  );
                } else if (cuisineName == 'Sweets') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CakePriceListApp(),
                    ),
                  );
                }
                // You can add other navigation logic for different cuisines here
              },
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      cuisineImage,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cuisineName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}