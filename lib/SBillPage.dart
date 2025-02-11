import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SBillPage extends StatefulWidget {
  final int loggedInBranchId;

  const SBillPage({Key? key, required this.loggedInBranchId}) : super(key: key);

  @override
  _SBillPageState createState() => _SBillPageState();
}

class _SBillPageState extends State<SBillPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/minoriiproject/sbillpage.php?branch_id=${widget.loggedInBranchId}'),
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            orders = data['orders'];
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

  void _showBillDetails(Map<String, dynamic> order) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40), // Reduced horizontal margin
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: EdgeInsets.all(16), // Reduced padding
            width: MediaQuery.of(context).size.width * 0.3, // Set width to 80% of screen width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Order ${order['id']}",
                    style: TextStyle(
                      fontSize: 20, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  ),
                ),
                SizedBox(height: 8), // Reduced spacing
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8),
                Text(
                  "Bill Number: ${order['bill_number']}",
                  style: TextStyle(fontSize: 14), // Reduced font size
                ),
                SizedBox(height: 6),
                Text(
                  "Order Time: ${order['order_time']}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  "Delivery Time: ${order['delivery_date_time'] ?? 'Not specified'}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  "Items:",
                  style: TextStyle(
                    fontSize: 16, // Reduced font size
                    fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                if (order['items'] is List)
                  ...order['items'].map<Widget>((item) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2), // Reduced padding
                      child: Text(
                        "- ${item['name']}",
                        style: TextStyle(fontSize: 14), // Reduced font size
                      ),
                    );
                  }).toList()
                else
                  Text(
                    "No items available",
                    style: TextStyle(fontSize: 14),
                  ),
                SizedBox(height: 16),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8),
                Text(
                  "Total Price: Rs.${order['total_price']}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  "Loyalty Points Used: ${order['loyalty_points'] ?? 0}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  "Remaining After Loyalty: Rs.${order['remaining_after_loyalty']}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  "Subscription Credit Used: Rs.${order['subscription_credit_used']}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  "Final Total: Rs.${order['final_total']}",
                  style: TextStyle(
                    fontSize: 18, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Reduced padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 14, // Reduced font size
                        color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : orders.isEmpty
                ? Center(
                    child: Text(
                      "No orders available.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            "Order ${order['id']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          ),
                          subtitle: Text("Bill Number: ${order['bill_number']}"),
                          trailing: Text(
                            "Rs.${order['final_total']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                          ),
                          onTap: () => _showBillDetails(order),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}