import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // List to store cart items
  final List<Map<String, dynamic>> _cartItems = [];

  // Getter for cart items
  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Getter for total price
  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  // Method to add an item to the cart
  void addToCart(Map<String, dynamic> item) {
    // Check if the item already exists in the cart
    int existingIndex =
        _cartItems.indexWhere((cartItem) => cartItem['title'] == item['title']);

    if (existingIndex != -1) {
      // If item exists, update the quantity
      _cartItems[existingIndex]['quantity'] += item['quantity'];
    } else {
      // If item does not exist, add it to the cart
      _cartItems.add({
        'title': item['title'],
        'price': item['price'],
        'quantity': item['quantity'],
      });
    }

    notifyListeners(); // Notify listeners to update UI
  }

  // Method to remove an item from the cart
  void removeFromCart(String title) {
    _cartItems.removeWhere((item) => item['title'] == title);
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to clear the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners(); // Notify listeners to update UI
  }
}
