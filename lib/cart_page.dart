import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'cartCheckout.dart'; // Import your CartCheckoutPage

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
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

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
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the Checkout page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const CartSummary(), // Navigate to checkout page
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
        ),
      ),
    );
  }

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