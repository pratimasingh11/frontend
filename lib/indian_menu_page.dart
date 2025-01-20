import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart'; // Import CartProvider

class IndianMenuPage extends StatefulWidget {
  const IndianMenuPage({super.key});

  @override
  _IndianMenuPageState createState() => _IndianMenuPageState();
}

class _IndianMenuPageState extends State<IndianMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Biryani',
      'image': 'assets/biryani.jpg',
      'price': 250,
      'quantity': 0,
    },
    {
      'title': 'Butter Chicken',
      'image': 'assets/butter_chicken.jpg',
      'price': 300,
      'quantity': 0,
    },
    {
      'title': 'Dosa',
      'image': 'assets/dosa.jpg',
      'price': 100,
      'quantity': 0,
    },
    {
      'title': 'Daal Makhni',
      'image': 'assets/daalmakhni.jpg',
      'price': 250,
      'quantity': 0,
    },
    {
      'title': 'Paneer Tikka',
      'image': 'assets/paneer tikka.jpg',
      'price': 350,
      'quantity': 0,
    },
    {
      'title': 'Paneer Chilly',
      'image': 'assets/paneer chilly.jpg',
      'price': 550,
      'quantity': 0,
    },
    {
      'title': 'Chana Masala',
      'image': 'assets/chanamasala.jpg',
      'price': 550,
      'quantity': 0,
    },
  ];

  void addToCart(Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart({
      'title': item['title'],
      'price': item['price'],
      'quantity': item['quantity'],
    });
    setState(() {
      item['quantity'] = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['title']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Cuisine'),
        backgroundColor: const Color(0xFFFFC400),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                ),
              ),
            ),
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
                      color: Colors.orangeAccent,
                    ),
                  ),
                  Text(
                    'Rs. ${item['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
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
                          addToCart(item);
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
