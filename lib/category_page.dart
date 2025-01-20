import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'Nepali_menu_page.dart'; // Import NepaliMenuPage
import 'indian_menu_page.dart';
import 'chinese_menu_page.dart';
import 'italian_page.dart';
import 'soft drinks.dart';
import 'sweets.dart'; // Import the correct SweetsPage

class CategoryPage extends StatelessWidget {
  // Temporary customer name for display; replace this with backend logic
  final String customerName = "John";

  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'Raleway', // Modern and elegant font
            fontSize: 22, // Slightly larger size for emphasis
            fontWeight: FontWeight.bold, // Italicized for style
            color: Colors.black, // Black color for contrast
          ),
        ),
        backgroundColor:
            const Color(0xFFFFC400), // A richer yellow for better appearance
      ),
      body: Column(
        children: [
          // Greeting and Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $customerName',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26, // Slightly larger font for a welcoming feel
                    fontWeight: FontWeight.w600, // Semi-bold for emphasis
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Grab your delicious meal!',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(
                        255, 18, 18, 18), // Subtle gray for contrast
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: Colors.black, // Light gray for the placeholder
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cuisine Grid Section
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 20, // Space between columns
              mainAxisSpacing: 20, // Space between rows
              padding: const EdgeInsets.all(16),
              childAspectRatio: 0.75, // Adjust to increase height of containers
              children: [
                buildCategoryCard(context, 'Nepali', 'assets/nepali.jpg',
                    const NepaliMenuPage()),
                buildCategoryCard(context, 'Indian', 'assets/indian.jpg',
                    const IndianMenuPage()),
                buildCategoryCard(context, 'Chinese', 'assets/chinese.jpg',
                    const ChineseMenuPage()),
                buildCategoryCard(context, 'Italian', 'assets/italian.jpg',
                    const ItalianMenuPage()),
                buildCategoryCard(context, 'Sweets', 'assets/sweets.jpg',
                    const CakePriceListApp()),
                buildCategoryCard(context, 'Soft Drinks',
                    'assets/soft_drinks.jpg', const SoftDrinksMenuPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard(
      BuildContext context, String title, String imagePath, Widget page) {
    return GestureDetector(
      onTap: () {
        // Navigate to the respective page when a category is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFC400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: CircleAvatar(
                  radius: 50, // Adjust as needed
                  backgroundImage: AssetImage(imagePath),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                title, // Cuisine titles
                style: const TextStyle(
                  fontFamily: 'Raleway', // Elegant and modern font
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
