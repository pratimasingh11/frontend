import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'cart_page.dart';
import 'providers/cart_provider.dart';

class MenuPage extends StatefulWidget {
  final int categoryId;
  final int loggedInBranchId;
  final int loggedInUserId;

  const MenuPage({
    super.key,
    required this.categoryId,
    required this.loggedInBranchId,
    required this.loggedInUserId,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<dynamic>> products;

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/minoriiproject/menuPage.php?category_id=${widget.categoryId}&branch_id=${widget.loggedInBranchId}&user_id=${widget.loggedInUserId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['products'];
        } else {
          throw Exception('No products found');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFDE21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CartPage(
        //             loggedInBranchId: widget.loggedInBranchId,
        //             loggedInUserId: widget.loggedInUserId,
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Price', 'Alphabetical', 'Popular', 'Rating']
                  .map((filter) => FilterChip(
                        label: Text(filter),
                        selected: false,
                        onSelected: (bool selected) {},
                        backgroundColor: const Color(0xFFFFDE21),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return buildProductCard(product);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final int productId = product['product_id'];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product['image_url'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          ),
        ),
        title: Text(
          product['product_name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Rs. ${product['product_price']}',
          style: const TextStyle(fontSize: 14, color: Colors.red),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                context.read<CartProvider>().updateQuantity(productId, -1);
              },
            ),
            Consumer<CartProvider>(builder: (context, cartProvider, _) {
              final quantity =
                  cartProvider.cartItems[productId]?['quantity'] ?? 0;
              return Text('$quantity', style: const TextStyle(fontSize: 18));
            }),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.read<CartProvider>().updateQuantity(productId, 1);
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              onPressed: () {
                context.read<CartProvider>().addToCart({
                  'product_id': product['product_id'],
                  'image': product['image_url'],
                  'name': product['product_name'],
                  'price': product['product_price'],
                  'quantity': 1,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
