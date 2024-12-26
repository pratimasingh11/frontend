import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedItems = [
    {
      "name": "Cheese Pizza",
      "price": 500,
      "rating": 3.8,
      "image": "assets/cheese_pizza.png"
    },
    {
      "name": "Veg Burger",
      "price": 250,
      "rating": 4.2,
      "image": "assets/veg_burger.jpg"
    },
    {
      "name": "Pasta",
      "price": 350,
      "rating": 4.5,
      "image": "assets/pasta.jpg"
    },
    {
      "name": "French Fries",
      "price": 150,
      "rating": 4.0,
      "image": "assets/fries.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Item
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        "assets/chicken_biryani.jpg",
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        "Chicken Biryani",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Rs. 455",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: Colors.black),
                            onPressed: () {
                              // Add logic to increment the item quantity
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              // Add logic to remove the item from the cart
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          minimumSize: Size(double.infinity, 60),
                        ),
                        onPressed: () {
                          // Add logic to add more items to the cart
                        },
                        icon: Icon(Icons.add, color: Colors.black),
                        label: Text(
                          "Add more items",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // "You May Also Like" Section
              Text(
                "You May Also Like!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Recommended items list
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedItems.length,
                  itemBuilder: (context, index) {
                    final item = recommendedItems[index];
                    return Card(
                      margin: EdgeInsets.only(right: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item["image"],
                                height: 100,
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item["name"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text("${item["rating"]}"),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, color: Colors.black),
                                    onPressed: () {
                                      // Add logic to add this item to the cart
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Rs. ${item["price"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              // Subtotal and Confirm Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rs. 455",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add logic for confirming the delivery details
                },
                child: Center(
                  child: Text(
                    "Confirm Order",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  minimumSize: Size(double.infinity, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 