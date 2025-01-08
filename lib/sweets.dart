import 'package:flutter/material.dart';

void main() {
  runApp(const CakePriceListApp());
}

class CakePriceListApp extends StatelessWidget {
  const CakePriceListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CakePriceListScreen(),
    );
  }
}

class CakePriceListScreen extends StatefulWidget {
  const CakePriceListScreen({super.key});

  @override
  _CakePriceListScreenState createState() => _CakePriceListScreenState();
}

class _CakePriceListScreenState extends State<CakePriceListScreen> {
  final List<Map<String, dynamic>> cakes = [
    {
      'title': 'Strawberry Cake',
      'price': 25,
      'quantity': 0,
      'image': 'assets/strawberryCake.jpg'
    },
    {
      'title': 'Choco Fudge Cake',
      'price': 25,
      'quantity': 0,
      'image': 'assets/chocoFudge.jpg'
    },
    {
      'title': 'Red Velvet Cake',
      'price': 25,
      'quantity': 0,
      'image': 'assets/redvelvetcake.jpg'
    },
    {
      'title': 'Tiramisu Cake',
      'price': 25,
      'quantity': 0,
      'image': 'assets/tiramisu.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cake Menu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFFF9E5), // Light off-white background
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cakes.length,
            itemBuilder: (context, index) {
              final cake = cakes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Cake Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          cake['image'], // Add the image file path here
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                          width: 16), // Spacing between image and text
                      // Cake Title and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cake['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${cake['price']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity Controls and Cart Icon
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (cake['quantity'] > 0) {
                                  cake['quantity']--;
                                }
                              });
                            },
                          ),
                          Text(
                            '${cake['quantity']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.add, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                cake['quantity']++;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.shopping_cart, color: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}