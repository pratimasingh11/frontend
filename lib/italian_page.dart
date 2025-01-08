import 'package:flutter/material.dart';

class ItalianMenuPage extends StatefulWidget {
  const ItalianMenuPage({super.key});

  @override
  _ItalianMenuPageState createState() => _ItalianMenuPageState();
}

class _ItalianMenuPageState extends State<ItalianMenuPage> {
  int quantity = 0;

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Chicken Pizza',
      'price': 500,
      'image': 'assets/chicken pizza.jpg'
    },
    {
      'name': 'Chicken Pasta',
      'price': 600,
      'image': 'assets/chicken pasta.jpg'
    },
    {
      'name': 'Spinach Spaghetti',
      'price': 550,
      'image': 'assets/spinach spaghetti.jpg'
    },
    {
      'name': 'Spicy Spaghetti',
      'price': 700,
      'image': 'assets/spicy spaghetti.jpg'
    },
    {'name': 'Pesto Pasta', 'price': 800, 'image': 'assets/pesto pasta.jpg'},
    {'name': 'Pepperoni Pizza', 'price': 1200, 'image': 'assets/pizza.jpg'},
    {
      'name': 'Magherita Pizza',
      'price': 990,
      'image': 'assets/magherita pizza.jpg'
    },
    {'name': 'Lasagna', 'price': 550, 'image': 'assets/lasagna.jpg'},
    {'name': 'Ravioli', 'price': 880, 'image': 'assets/ravioli.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow, // Yellow background
        title: const Text(
          'Italian Menu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFFFF9E5), // Light off-white background
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: menuItems.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  color: Colors.white, // White background for each item
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Image on the left side
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            item['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                            width: 16), // Space between image and text
                        // Item details (name, price, quantity controls, cart)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${item['price']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red, // Red color for price
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quantity controls and cart icon
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) {
                                    quantity--;
                                  }
                                });
                              },
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.shopping_cart,
                                color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}