import 'package:flutter/material.dart';

class ChineseMenuPage extends StatefulWidget {
  const ChineseMenuPage({super.key});

  @override
  _ChineseMenuPageState createState() => _ChineseMenuPageState();
}

class _ChineseMenuPageState extends State<ChineseMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Fried Rice',
      'image': 'assets/friedrice.jpg', // Corrected image path
      'price': 'Rs. 200',
      'quantity': 0,
    },
    {
      'title': 'Spring Roll',
      'image': 'assets/springroll.jpg', // Corrected image path
      'price': 'Rs. 150',
      'quantity': 0,
    },
    {
      'title': 'Chowmein',
      'image': 'assets/chowmen.jpg', // Corrected image path
      'price': 'Rs. 180',
      'quantity': 0,
    },
    {
      'title': 'Manchurian',
      'image': 'assets/manchurian.jpg', // Corrected image path
      'price': 'Rs. 250',
      'quantity': 0,
    },
    {
      'title': 'Kung Pao Chicken',
      'image': 'assets/kung pao chicken.jpg', // Corrected image path
      'price': 'Rs 280',
      'quantity': 0,
    },
    {
      'title': 'Chicken Wonton Soup',
      'image': 'assets/chicken wonton soup.jpg', // Corrected image path
      'price': 'Rs 300',
      'quantity': 0,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Off-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC400), // Yellow top bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Chinese Menu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0), // Space between boxes
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // White rectangle box
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
                        const SizedBox(
                            width: 16), // Space between image and text
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
                              const SizedBox(height: 4),
                              Text(
                                item['price'],
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
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  size: 20, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  menuItems[index]['quantity']++;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart,
                                  size: 24, color: Colors.green),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text('${item['title']} added to cart!'),
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
            ),
          ],
        ),
      ),
    );
  }
}
