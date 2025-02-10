import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'OrderBillDetailsPage.dart'; // Import the OrderBillDetailsPage

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
      // Pass the branch ID as a query parameter
      final response = await http.get(
        Uri.parse('http://localhost/minoriiproject/sbillpage.php?branch_id=${widget.loggedInBranchId}'),
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            orders = data['orders']; // Assuming the server returns the orders for the branch
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BILL LISTS"),
        backgroundColor: Colors.yellow.shade700, // Optional: Match AppBar color with the theme
      ),
      body: Container(
        color: Colors.yellow.shade700, // Set the background color of the entire page
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text("No orders available."))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 4, // Add elevation for a shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners for the card
                        ),
                        child: ListTile(
                          title: Text(
                            "Order ${order['id']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("Bill Number: ${order['bill_number']}"),
                          trailing: Text(
                            "\$${order['final_total']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green, // Customize the price color
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderBillDetailsPage(
                                    order: order), // Pass the order to the details page
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}