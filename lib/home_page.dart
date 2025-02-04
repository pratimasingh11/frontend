import 'package:flutter/material.dart';
import 'signup_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFEB3B),
              Color(0xFFFFF9C4)
            ], // Updated to yellow gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Top Banner Image with Rounded Corners and Shadow
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/burger.jpg', // Replace this with your image path
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Title and Description with Animated Effect
            Column(
              children: [
                Text(
                  'Delicious FOODS',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800], // Updated to yellow shade
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Let us help you discover\n the best food',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // Features Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.star,
                          size: 40,
                          color: Color(0xFFFFC107)), // Yellow for Quality Meals
                      SizedBox(height: 5),
                      Text(
                        'Quality Meals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.food_bank, size: 40, color: Color(0xFFFFC107)),
                      SizedBox(height: 5),
                      Text(
                        'Fresh & Tasty',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 40, color: Color(0xFFFFC107)),
                      SizedBox(height: 5),
                      Text(
                        'Wide Variety',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFFDE21), // Updated to yellow shade
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}