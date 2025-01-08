import 'package:flutter/material.dart';

void main() {
  runApp(const CakePriceListApp());
}

class CakePriceListApp extends StatelessWidget {
  const CakePriceListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFF1E5), // Light pink background
        body: SafeArea(
          child: CakePriceListScreen(),
        ),
      ),
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
      'image': 'assets/strawberryCake.jpg',
      'price': '\$25',
      'quantity': 0
    },
    {
      'title': 'Choco Fudge Cake',
      'image': 'assets/chocoFudge.jpg',
      'price': '\$25',
      'quantity': 0
    },
    {
      'title': 'Red Velvet Cake',
      'image': 'assets/redvelvetcake.jpg',
      'price': '\$25',
      'quantity': 0
    },
    {
      'title': 'Tiramisu Cake',
      'image': 'assets/tiramisu.jpg',
      'price': '\$25',
      'quantity': 0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Drip Image
        Positioned.fill(
          child: Image.asset(
            'assets/drip.jpg', // Replace with your drip image
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to the previous page
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.brown,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space from the arrow
            const Center(
              child: Text(
                'Cake',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cursive',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: cakes.length,
                itemBuilder: (context, index) {
                  final cake = cakes[index];
                  final isRightAligned = index % 2 != 0; // 2nd and 4th items
                  return buildCakeItem(
                    cake,
                    isRightAligned,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCakeItem(
      Map<String, dynamic> cake, bool isRightAligned, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment:
            isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isRightAligned)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cake['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cake['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove,
                          size: 18, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          if (cake['quantity'] > 0) {
                            cakes[index]['quantity']--;
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
                          const Icon(Icons.add, size: 18, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          cakes[index]['quantity']++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          if (isRightAligned) const SizedBox(width: 16),
          ClipOval(
            child: Image.asset(
              cake['image'],
              width: 80, // Adjusted image size
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          if (!isRightAligned) const SizedBox(width: 16),
          if (!isRightAligned)
            Column(
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
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cake['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove,
                          size: 18, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          if (cake['quantity'] > 0) {
                            cakes[index]['quantity']--;
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
                          const Icon(Icons.add, size: 18, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          cakes[index]['quantity']++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
