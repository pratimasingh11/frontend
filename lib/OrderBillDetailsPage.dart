import 'package:flutter/material.dart';

class OrderBillDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderBillDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order ${order['id']} Bill")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bill Number: ${order['bill_number']}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Order Time: ${order['order_time']}"),
            Text(
                "Delivery Time: ${order['delivery_date_time'] ?? 'Not specified'}"),
            const SizedBox(height: 20),
            const Text("Items:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (order['items'] is List)
              ...order['items'].map<Widget>((item) {
                return Text(
                  "- ${item['name']}", // Show only the item name
                  style: const TextStyle(fontSize: 14),
                );
              }).toList()
            else
              const Text("No items available"),
            const SizedBox(height: 20),
            Text("Total Price: \$${order['total_price']}"),
            Text("Loyalty Points Used: ${order['loyalty_points'] ?? 0}"),
            Text(
                "Remaining After Loyalty: \$${order['remaining_after_loyalty']}"),
            Text(
                "Subscription Credit Used: \$${order['subscription_credit_used']}"),
            Text("Final Total: \$${order['final_total']}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
