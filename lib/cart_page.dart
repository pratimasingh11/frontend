import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'cartCheckout.dart';

class CartPage extends StatelessWidget {
  final int loggedInBranchId;
  final int loggedInUserId;

  const CartPage({
    super.key,
    required this.loggedInBranchId,
    required this.loggedInUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: const Color(0xFFFFDE21),
      ),
      body: Consumer<CartProvider>(
        // Consumer listens for cart changes
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          // Calculate totalAmount (sum of item price * quantity)
          double totalAmount =
              cartProvider.cartItems.values.fold(0, (sum, item) {
            double price = double.tryParse(item['price'].toString()) ?? 0.0;
            int quantity = item['quantity'] ?? 0;
            return sum + (price * quantity);
          });

          return ListView.builder(
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final product = cartProvider.cartItems.values.toList()[index];
              return buildCartItem(product, cartProvider);
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<CartProvider>(
          // Recalculating total on cart change
          builder: (context, cartProvider, _) {
            // Calculate totalAmount (sum of item price * quantity)
            double totalAmount =
                cartProvider.cartItems.values.fold(0, (sum, item) {
              double price = double.tryParse(item['price'].toString()) ?? 0.0;
              int quantity = item['quantity'] ?? 0;
              return sum + (price * quantity);
            });

            return ElevatedButton(
              onPressed: () {
                // Navigate to the Checkout page with necessary parameters
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartSummary(
                      loggedInBranchId: loggedInBranchId,
                      loggedInUserId: loggedInUserId, // Pass user ID here
                      totalAmount: totalAmount, // Pass total amount here
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDE21), // Button color
                foregroundColor: Colors.black, // Text color
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Proceed to Checkout'),
            );
          },
        ),
      ),
    );
  }

  // Build individual cart item widget
  Widget buildCartItem(
      Map<String, dynamic> product, CartProvider cartProvider) {
    final productId = product['product_id'];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
            child: Image.network(
              product['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${double.tryParse(product['price'].toString())?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        cartProvider.updateQuantity(productId, -1);
                      },
                    ),
                    Text(
                      '${product['quantity']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        cartProvider.updateQuantity(productId, 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Item Button
          IconButton(
            icon: const Icon(Icons.remove_shopping_cart),
            onPressed: () {
              cartProvider.removeFromCart(productId);
            },
          ),
        ],
      ),
    );
  }
}