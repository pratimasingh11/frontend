import 'package:flutter/material.dart';

class IndianMenuPage extends StatefulWidget {
  const IndianMenuPage({super.key});

  @override
  _IndianMenuPageState createState() => _IndianMenuPageState();
}

class _IndianMenuPageState extends State<IndianMenuPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Biryani',
      'image': 'assets/biryani.jpg',
      'price': 'Rs. 250',
      'quantity': 0,
    },
    {
      'title': 'Butter Chicken',
      'image': 'assets/butter_chicken.jpg',
      'price': 'Rs. 300',
      'quantity': 0,
    },
    {
      'title': 'Dosa',
      'image': 'assets/dosa.jpg',
      'price': 'Rs. 100',
      'quantity': 0,
    },
    {
      'title': 'DaalMakhni',
      'image': 'assets/daalmakhni.jpg',
      'price': 'Rs. 250',
      'quantity': 0,
    },
    {
      'title': 'PaneerTikka',
      'image': 'assets/paneer tikka.jpg',
      'price': 'Rs. 350',
      'quantity': 0,
    },
    {
      'title': 'Paneer Chilly',
      'image': 'assets/paneer chilly.jpg',
      'price': 'Rs. 550',
      'quantity': 0,
    },
    {
      'title': 'Chana Masala',
      'image': 'assets/chanamasala.jpg',
      'price': 'Rs. 550',
      'quantity': 0,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Cuisine'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Menu List (Scrollable) with limited space
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(menuItems.length, (index) {
                    final item = menuItems[index];
                    return buildMenuItem(item, index);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Menu Item widget
  Widget buildMenuItem(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced padding
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Image
            ClipOval(
              child: Image.asset(
                item['image'],
                width: 70, // Reduced image size
                height: 70, // Reduced image size
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12), // Reduced space between image and text
            // Item name, price, and quantity control
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height:
                          10), // Increased space to move name and price down
                  // Title at the top
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16, // Slightly smaller font size
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(
                      height: 4), // Reduced space between title and price
                  // Price below the title
                  Text(
                    item['price'],
                    style: const TextStyle(
                      fontSize: 14, // Smaller font size for price
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 8), // Space for quantity and cart icons
                  // Row for quantity control (-, +) and cart icon
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove,
                            size: 18, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 0) {
                              menuItems[index]['quantity']--;
                            }
                          });
                        },
                      ),
                      Text(
                        '${item['quantity']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            menuItems[index]['quantity']++;
                          });
                        },
                      ),
                      const Spacer(), // To push cart icon to the right
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            size: 24, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${item['title']} added to cart!'),
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}