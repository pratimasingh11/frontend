import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SOrdersPage extends StatefulWidget {
  final int loggedInBranchId;
  const SOrdersPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _SOrdersPageState createState() => _SOrdersPageState();
}

class _SOrdersPageState extends State<SOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  int? expandedOrderId; // To track which order's details are expanded

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');

      if (sessionId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/SOrders.php'),
        headers: {
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'branch_id': widget.loggedInBranchId}),
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            orders = data['orders']; // Get orders from response
            isLoading = false;
          });
        } else {
          print("Error Message: ${data['message']}");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Server Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Network Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleDetails(int orderId) {
    setState(() {
      if (expandedOrderId == orderId) {
        expandedOrderId = null; // Collapse if already expanded
      } else {
        expandedOrderId = orderId; // Expand the clicked order
      }
    });
  }

  Future<void> _markDelivered(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');

      if (sessionId == null) {
        print("Session ID is missing");
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/MarkDelivered.php'),
        headers: {
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      print("Mark Delivered Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Refresh the orders list
          _fetchOrders();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order $orderId marked as delivered")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error marking delivered: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Orders"),
      backgroundColor: Colors.yellow.shade700, // AppBar color
    ),
    body: Container(
      color: Colors.yellow.shade700, // Background color for the entire page
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders available."))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isExpanded = expandedOrderId == order['order_id'];
                    final isDelivered = order['status'] == 'delivered';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4, // Add shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "Order ${order['order_id']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Bill Number: ${order['bill_number']}"),
                            trailing: ElevatedButton(
                              onPressed: isDelivered
                                  ? null // Disable button if delivered
                                  : () => _markDelivered(order['order_id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDelivered
                                    ? Colors.brown // Brown background if delivered
                                    : Colors.green, // Green background if pending
                                foregroundColor: Colors.white, // Text color
                              ),
                              child: Text(
                                isDelivered ? "Delivered" : "Mark Delivered",
                              ),
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Items:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...(order['items'] as List<dynamic>).map((item) {
                                    return Text(
                                      "- ${item['item_name']} (Quantity: ${item['quantity']}, Price: \$${item['price']})",
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                  Text("Final Total: \$${order['final_total']}"),
                                  Text(
                                      "Delivery Time: ${order['delivery_date_time']}"),
                                ],
                              ),
                            ),
                          InkWell(
                            onTap: () => _toggleDetails(order['order_id']),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isExpanded ? "Hide Details" : "View Details",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    ),
  );
}
}