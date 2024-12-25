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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/indianbackground2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Back Arrow
          Positioned(
            top: 20.0, // Adjust the position for better alignment
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          // Scrollable Content
          Column(
            children: [
              // Static Title with adjusted padding for lower position
              Container(
                padding: const EdgeInsets.only(top: 100.0), // Increased padding
                alignment: Alignment.center,
                child: const Text(
                  'Indian Cuisine',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 30, // Font size remains the same
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cursive',
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacer between title and menu

              // Menu List (Scrollable) with limited space
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final isRightAligned =
                            index % 2 != 0; // Alternate items
                        return buildMenuItem(item, isRightAligned, index);
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Menu Item widget
  Widget buildMenuItem(
      Map<String, dynamic> item, bool isRightAligned, int index) {
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
                  item['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      icon:
                          const Icon(Icons.add, size: 18, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          menuItems[index]['quantity']++;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart,
                          size: 28, color: Colors.green), // Cart Icon
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
          if (isRightAligned) const SizedBox(width: 16),
          ClipOval(
            child: Image.asset(
              item['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          if (!isRightAligned) const SizedBox(width: 16),
          if (!isRightAligned)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      icon:
                          const Icon(Icons.add, size: 18, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          menuItems[index]['quantity']++;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart,
                          size: 28, color: Colors.green), // Cart Icon
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
        ],
      ),
    );
  }
}
