import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart'; // Import the CartProvider
import 'welcome_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontFamily: 'Raleway', // Modern and elegant font
            fontSize: 22, // Slightly larger size for emphasis
            fontWeight: FontWeight.bold, // Italicized for style
            color: Colors.black, // Black color for contrast
          ),
        ),
        backgroundColor:
            const Color(0xFFFFC400), // A richer yellow for better appearance
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Text('No items in the cart.'),
            );
          }
          return ListView.builder(
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartProvider.cartItems[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Text('Quantity: ${item['quantity']}'),
                trailing: Text('Rs. ${item['price'] * item['quantity']}'),
              );
            },
          );
        },
      ),
    );
  }
}
