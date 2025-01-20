import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart'; // Import CartProvider

class ItalianMenuPage extends StatefulWidget {
  const ItalianMenuPage({super.key});

  @override
  _ItalianMenuPageState createState() => _ItalianMenuPageState();
}

class _ItalianMenuPageState extends State<ItalianMenuPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Chicken Pizza',
      'price': 500,
      'image': 'assets/chicken pizza.jpg',
      'quantity': 0, // Add a quantity field for each item
    },
    {
      'name': 'Chicken Pasta',
      'price': 600,
      'image': 'assets/chicken pasta.jpg',
      'quantity': 0,
    },
    {
      'name': 'Spinach Spaghetti',
      'price': 550,
      'image': 'assets/spinach spaghetti.jpg',
      'quantity': 0,
    },
    {
      'name': 'Spicy Spaghetti',
      'price': 700,
      'image': 'assets/spicy spaghetti.jpg',
      'quantity': 0,
    },
    {
      'name': 'Pesto Pasta',
      'price': 800,
      'image': 'assets/pesto pasta.jpg',
      'quantity': 0,
    },
    {
      'name': 'Pepperoni Pizza',
      'price': 1200,
      'image': 'assets/pizza.jpg',
      'quantity': 0,
    },
    {
      'name': 'Magherita Pizza',
      'price': 990,
      'image': 'assets/magherita pizza.jpg',
      'quantity': 0,
    },
    {
      'name': 'Lasagna',
      'price': 550,
      'image': 'assets/lasagna.jpg',
      'quantity': 0,
    },
    {
      'name': 'Ravioli',
      'price': 880,
      'image': 'assets/ravioli.jpg',
      'quantity': 0,
    },
  ];

  final TextEditingController _searchController = TextEditingController();

  // Add this method to handle adding items to the cart
  void addToCart(Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart({
      'title': item['name'],
      'price': item['price'],
      'quantity': item['quantity'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
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
        color: const Color(0xFFFFF9E5),
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search field with white background
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true, // Set to true to fill the background
                      fillColor:
                          Colors.white, // Set the background color to white
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none, // Remove the border
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {}); // Trigger a rebuild when search changes
                    },
                  ),
                ),

                // Menu items list
                Column(
                  children: menuItems.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      color: Colors.white,
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
                                      color: Colors.red,
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
                                      if (item['quantity'] > 0) {
                                        item['quantity']--;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '${item['quantity']}',
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
                                      item['quantity']++;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    if (item['quantity'] > 0) {
                                      addToCart(item);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please select a quantity!'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
