import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // A map to store cart items, where the key is the product ID
  final Map<int, Map<String, dynamic>> _cartItems = {};

  // Getter to access cart items
  Map<int, Map<String, dynamic>> get cartItems => _cartItems;

  // Add product to cart
  void addToCart(Map<String, dynamic> product) {
    int productId = product['product_id'];

    if (_cartItems.containsKey(productId)) {
      _cartItems[productId]!['quantity']++;
    } else {
      _cartItems[productId] = {
        'product_id': productId, // Ensure product ID is stored
        'image': product['image'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      };
    }
    notifyListeners(); // Notify listeners that the cart has changed
  }

  // Update quantity of a product
  void updateQuantity(int productId, int change) {
    if (_cartItems.containsKey(productId)) {
      int newQuantity = (_cartItems[productId]!['quantity'] as int) + change;

      if (newQuantity > 0) {
        _cartItems[productId]!['quantity'] = newQuantity;
      } else {
        _cartItems.remove(productId); // Removes item if quantity reaches 0
      }

      notifyListeners(); // Notify listeners that the cart has changed
    }
  }

  // Remove product from cart
  void removeFromCart(int productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.remove(productId);
      notifyListeners(); // Notify listeners that the cart has changed
    }
  }
}
