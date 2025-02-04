import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    double totalPrice = cartItems.values.fold(0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Summary'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell("Item Name", true),
                    tableCell("Quantity", true),
                    tableCell("Price", true),
                  ],
                ),
                ...cartItems.entries.map((entry) {
                  var item = entry.value;
                  return TableRow(children: [
                    tableCell(item['name']),
                    tableCell(item['quantity'].toString()),
                    tableCell(
                        "₹${(double.tryParse(item['price'].toString()) ?? 0.0) * (int.tryParse(item['quantity'].toString()) ?? 0)}"),
                  ]);
                })
              ],
            ),
            const SizedBox(height: 16),
            costRow("Original Cost", totalPrice.toDouble()),
          ],
        ),
      ),
    );
  }

  // Utility function for table cells
  Widget tableCell(String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  // Utility function for cost rows
  Widget costRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text("₹${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
