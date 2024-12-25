import 'package:flutter/material.dart';

class SellersDashboard extends StatefulWidget {
  const SellersDashboard({super.key});

  @override
  _SellersDashboardState createState() => _SellersDashboardState();
}

class _SellersDashboardState extends State<SellersDashboard> {
  String selectedSection = ""; // Track the selected section

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Orders', 'icon': Icons.shopping_cart},
    {'title': 'Categories', 'icon': Icons.category},
    {'title': 'Products', 'icon': Icons.store},
    {'title': 'Bill Lists', 'icon': Icons.receipt_long},
    {'title': 'Reports', 'icon': Icons.analytics},
    {'title': 'Inventory', 'icon': Icons.inventory},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Section
          Container(
            width: 250,
            color: const Color(0xFFF8F9FA), // Light background for the menu
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture and Branch Name
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/profile_picture.png'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Branch Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading:
                            Icon(menuItems[index]['icon'], color: Colors.black),
                        title: Text(menuItems[index]['title']),
                        onTap: () {
                          setState(() {
                            selectedSection = menuItems[index]['title'];
                          });
                        },
                        selected: selectedSection == menuItems[index]['title'],
                        selectedTileColor: Colors.blue.shade100,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Section
          Expanded(
            child: Container(
              color: Colors.white, // Background for content section
              child: Center(
                child: Text(
                  selectedSection.isNotEmpty
                      ? 'Displaying $selectedSection'
                      : 'Select an item from the left menu',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SellersDashboard(),
  ));
}
