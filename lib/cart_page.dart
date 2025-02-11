import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'cartCheckout.dart'; // Import your CartCheckoutPage
// Import WelcomePage

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 246, 238, 194),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          double totalAmount =
              cartProvider.cartItems.values.fold(0, (sum, item) {
            double price = double.tryParse(item['price'].toString()) ?? 0.0;
            int quantity = item['quantity'] ?? 0;
            return sum + (price * quantity);
          });

          return Column(
            children: [
              const SizedBox(height: 16), // Space between AppBar and List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final product =
                        cartProvider.cartItems.values.toList()[index];
                    return buildCartItem(product, cartProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            double totalAmount =
                cartProvider.cartItems.values.fold(0, (sum, item) {
              double price = double.tryParse(item['price'].toString()) ?? 0.0;
              int quantity = item['quantity'] ?? 0;
              return sum + (price * quantity);
            });

            return ElevatedButton(
              onPressed: cartProvider.cartItems.isEmpty
                  ? () {
                      // Show a SnackBar when the cart is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add to cart first'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartCheckout(
                            loggedInBranchId: loggedInBranchId,
                            loggedInUserId: loggedInUserId,
                            totalAmount: totalAmount,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDE21), // Button color
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Proceed to Checkout'),
            );
          },
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
          // Increased left padding for the image
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
          ),
          const SizedBox(width: 16), // Space between image and details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
          const SizedBox(
              width: 8), // Reduced space between details and remove icon
          IconButton(
            icon: const Icon(
              Icons.remove_shopping_cart,
              size: 30,
            ),
            color: Colors.red,
            onPressed: () {
              print('Removing product with ID: $productId');
              cartProvider.removeFromCart(productId);
            },
          ),
        ],
      ),
    );
  }
}