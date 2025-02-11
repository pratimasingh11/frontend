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
  int? expandedOrderId;

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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            orders = data['orders'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleDetails(int orderId) {
    setState(() {
      if (expandedOrderId == orderId) {
        expandedOrderId = null;
      } else {
        expandedOrderId = orderId;
      }
    });
  }

  Future<void> _markDelivered(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');

      if (sessionId == null) return;

      final response = await http.post(
        Uri.parse('http://localhost/minoriiproject/MarkDelivered.php'),
        headers: {
          'X-Session-ID': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _fetchOrders();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order $orderId marked as delivered")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF176), // Light yellow
              Color(0xFFFFD54F), // Medium yellow
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : orders.isEmpty
                      ? Center(
                          child: Text(
                            "No orders available.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final isExpanded = expandedOrderId == order['order_id'];
                            final isDelivered = order['status'] == 'delivered';

                            return Container(
                              margin: EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: isExpanded,
                                onExpansionChanged: (expanded) {
                                  _toggleDetails(order['order_id']);
                                },
                                title: Text(
                                  "Order ${order['order_id']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "Bill Number: ${order['bill_number']}",
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.black87,
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Items:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        ...(order['items'] as List<dynamic>).map((item) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text(
                                              "- ${item['item_name']} (Quantity: ${item['quantity']}, Price: \$${item['price']})",
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        SizedBox(height: 10),
                                        Text(
                                          "Final Total: \$${order['final_total']}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "Delivery Time: ${order['delivery_date_time']}",
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: isDelivered
                                                ? null
                                                : () => _markDelivered(order['order_id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDelivered
                                                  ? Colors.grey
                                                  : Color(0xFFFFA000), // Amber color
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: Text(
                                              isDelivered ? "Delivered" : "Mark Delivered",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}