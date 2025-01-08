import 'package:flutter/material.dart';

class NepaliMenuPage extends StatefulWidget {
  NepaliMenuPage({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Momo',
      'image': 'assets/momo.jpg',
      'price': 'Rs. 150',
      'quantity': 0,
    },
    {
      'title': 'Thukpa',
      'image': 'assets/thukpa.jpg',
      'price': 'Rs. 200',
      'quantity': 0,
    },
    {
      'title': 'Chatamaari',
      'image': 'assets/chataamari.jpg',
      'price': 'Rs. 100',
      'quantity': 0,
    },
    {
      'title': 'Sel Roti',
      'image': 'assets/selroti.jpg',
      'price': 'Rs. 20',
      'quantity': 0,
    },
    {
      'title': 'Khana Set (Veg)',
      'image': 'assets/khana set veg.jpg',
      'price': 'Rs. 350',
      'quantity': 0,
    },
    {
      'title': 'Khana Set (Chicken)',
      'image': 'assets/khanaset nonveg.jpg',
      'price': 'Rs. 500',
      'quantity': 0,
    },
    {
      'title': 'Yomari',
      'image': 'assets/yomari.jpg',
      'price': 'Rs. 80',
      'quantity': 0,
    },
    {
      'title': 'Newari Khaja Set',
      'image': 'assets/newari khaja set.jpg',
      'price': 'Rs. 250',
      'quantity': 0,
    },
    {
      'title': 'Parotha',
      'image': 'assets/parotha.jpg',
      'price': 'Rs. 40',
      'quantity': 0,
    },
  ];

  @override
  _NepaliMenuPageState createState() => _NepaliMenuPageState();
}

class _NepaliMenuPageState extends State<NepaliMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow, // Yellow background
        title: const Text(
          'Nepali Cuisine',
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
              children: widget.menuItems.map((item) {
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
                                item['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['price'],
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