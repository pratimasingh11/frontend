import 'package:flutter/material.dart';

class SoftDrinksMenuPage extends StatefulWidget {
  const SoftDrinksMenuPage({super.key});

  @override
  _SoftDrinksMenuPageState createState() => _SoftDrinksMenuPageState();
}

class _SoftDrinksMenuPageState extends State<SoftDrinksMenuPage> {
  Map<String, int> quantities = {};

  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Coca-Cola', 'price': 50, 'image': 'assets/coke.jpg'},
    {'name': 'Pepsi', 'price': 50, 'image': 'assets/pepsi.jpg'},
    {'name': 'Sprite', 'price': 50, 'image': 'assets/sprite.jpg'},
    {'name': 'Fanta', 'price': 50, 'image': 'assets/fanta.jpg'},
    {'name': 'Mountain Dew', 'price': 60, 'image': 'assets/mountain dew.jpg'},
    {'name': 'Black Coffee', 'price': 80, 'image': 'assets/black coffee.jpg'},
    {'name': 'Milk Tea', 'price': 30, 'image': 'assets/milk tea.jpg'},
    {'name': 'Black Tea', 'price': 20, 'image': 'assets/black tea.jpg'},
    {'name': 'Cappuccino', 'price': 120, 'image': 'assets/cappuccino.jpg'},
    {
      'name': 'Filter Coffee',
      'price': 100,
      'image': 'assets/filter coffee.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Soft Drinks Menu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    item['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Text(
                        '₹${item['price']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove,
                          size: 20, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          quantities[item['name']] =
                              (quantities[item['name']] ?? 0) > 0
                                  ? (quantities[item['name']] ?? 0) - 1
                                  : 0;
                        });
                      },
                    ),
                    Text(
                      '${quantities[item['name']] ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          quantities[item['name']] =
                              (quantities[item['name']] ?? 0) + 1;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart,
                          size: 24, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${item['name']} added to cart!'),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}