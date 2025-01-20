import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart'; // Import CartProvider
// Import CartPage

class SoftDrinksMenuPage extends StatefulWidget {
  const SoftDrinksMenuPage({super.key});

  @override
  _SoftDrinksMenuPageState createState() => _SoftDrinksMenuPageState();
}

class _SoftDrinksMenuPageState extends State<SoftDrinksMenuPage> {
  // Soft drinks menu items
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Coca-Cola',
      'image': 'assets/coke.jpg',
      'price': 50,
      'quantity': 0
    },
    {'title': 'Pepsi', 'image': 'assets/pepsi.jpg', 'price': 50, 'quantity': 0},
    {
      'title': 'Sprite',
      'image': 'assets/sprite.jpg',
      'price': 50,
      'quantity': 0
    },
    {'title': 'Fanta', 'image': 'assets/fanta.jpg', 'price': 50, 'quantity': 0},
    {
      'title': 'Mountain Dew',
      'image': 'assets/mountain dew.jpg',
      'price': 60,
      'quantity': 0
    },
    {
      'title': 'Black Coffee',
      'image': 'assets/black coffee.jpg',
      'price': 80,
      'quantity': 0
    },
    {
      'title': 'Milk Tea',
      'image': 'assets/milk tea.jpg',
      'price': 30,
      'quantity': 0
    },
    {
      'title': 'Black Tea',
      'image': 'assets/black tea.jpg',
      'price': 20,
      'quantity': 0
    },
    {
      'title': 'Cappuccino',
      'image': 'assets/cappuccino.jpg',
      'price': 120,
      'quantity': 0
    },
    {
      'title': 'Filter Coffee',
      'image': 'assets/filter coffee.jpg',
      'price': 100,
      'quantity': 0
    },
  ];

  // Add item to cart
  void addToCart(Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart({
      'title': item['title'],
      'price': item['price'],
      'quantity': item['quantity'],
      'image': item['image'],
    });

    setState(() {
      item['quantity'] = 0; // Reset quantity after adding to the cart
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['title']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soft Drinks Menu'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                item['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '₹${item['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            color: Colors.green),
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
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            size: 24, color: Colors.green),
                        onPressed: () {
                          addToCart(item); // Add item to cart when pressed
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
