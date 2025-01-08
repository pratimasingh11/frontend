import 'package:flutter/material.dart';
import 'category_page.dart'; // Import CategoryPage
import 'account.dart'; // Import the CakePriceListApp page

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // AppBar height
          child: AppBar(
            backgroundColor:
                const Color(0xFFFFC400), // Top section background color
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EazyMeals',
                  style: TextStyle(
                    fontSize: 20, // Adjusted font size of 'EazyMeals'
                    fontWeight: FontWeight.bold, // Make font bold
                    color: Colors.black,
                    fontFamily: 'Pacifico', // Make the font more attractive
                  ),
                ),
                // Search bar in the same row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
        ),
        body: Column(
          children: [
            // Offer section
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white, // Set the background color to white
                child: const Center(
                  child: Text(
                    'Special Offers',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 189, 55, 55),
                    ),
                  ),
                ),
              ),
            ),
            // Popular Menu Section
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white, // Set the background color to white
                child: const Center(
                  child: Text(
                    'Popular Menu',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 34, 19, 19),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor:
              const Color(0xFFFFC400), // Bottom navigation bar color
          selectedItemColor: Colors.black, // Selected item color
          unselectedItemColor: Colors.black, // Unselected item color
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
          ],
          onTap: (index) {
            // Handle bottom navigation here
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CakePriceListApp()),
              );
            } else if (index == 2) {
              // Navigate to CategoryPage when Categories is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage()),
              );
            }
          },
        ),
      ),
    );
  }
}