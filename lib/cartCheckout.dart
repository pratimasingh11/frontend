import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'webViewPage.dart';

class CartCheckout extends StatefulWidget {
  final int loggedInBranchId;
  final int loggedInUserId;
  final double totalAmount;

  const CartCheckout({
    super.key,
    required this.loggedInBranchId,
    required this.loggedInUserId,
    required this.totalAmount,
  });

  @override
  _CartCheckoutState createState() => _CartCheckoutState();
}

class _CartCheckoutState extends State<CartCheckout> {
  int remainingMeals = 0;
  DateTime? selectedDateTime;
  double loyaltyPoints = 0.0;
  double subscriptionCredit = 0.0;
  String userEmail = "";
  String branchName = "";
  bool _isLoading = false;

  final String apiUrl = "http://10.0.2.2/minoriiproject/loyaltyPoints.php";
  final String subscriptionUrl =
      "http://10.0.2.2/minoriiproject/subscription.php";
  final String paymentUrl =
      "http://10.0.2.2/minoriiproject/initiate_payment.php";
  final String getEmailUrl = "http://10.0.2.2/minoriiproject/cartCheckout.php";

  @override
  void initState() {
    super.initState();
    fetchEmailAndBranch();
    fetchLoyaltyPoints();

    final cartProvider = context.read<CartProvider>();
    fetchSubscriptionDetails(
        widget.loggedInUserId, cartProvider.cartItems.length);
  }

  Future<void> fetchEmailAndBranch() async {
    if (widget.loggedInUserId == 0) return;
    try {
      final response = await http.post(
        Uri.parse(getEmailUrl),
        body: {"user_id": widget.loggedInUserId.toString()},
      );

      final data = json.decode(response.body);
      if (data["success"] == true) {
        setState(() {
          userEmail = data["email"];
          branchName = data["branch_name"];
        });
      }
    } catch (e) {
      print("Error fetching email and branch: $e");
    }
  }

  Future<void> fetchLoyaltyPoints() async {
    if (widget.totalAmount <= 0) return;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"total_cost": widget.totalAmount.toString()},
      );

      final data = json.decode(response.body);
      if (data.containsKey("earned_points")) {
        setState(() {
          loyaltyPoints =
              double.tryParse(data["earned_points"].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching loyalty points: $e");
    }
  }

  Future<void> fetchSubscriptionDetails(int userId, int itemsOrdered) async {
    final response = await http.post(
      Uri.parse(subscriptionUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'user_id': userId,
        'items_ordered': itemsOrdered,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          subscriptionCredit = data['subscription_credit'];
          remainingMeals = data['remaining_meals'];
        });
      } else {
        print("Error: ${data['message']}");
      }
    } else {
      print("Failed to fetch subscription details");
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) return; // Add this line to handle null case

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> initiatePayment(double totalAmount) async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select delivery date & time")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    double totalPrice = totalAmount;
    double finalTotal = totalAmount;
    await saveOrderDetails(totalPrice, finalTotal);

    try {
      final response = await http.post(
        Uri.parse(paymentUrl),
        body: {
          "amount": totalAmount.toString(),
          "user_id": widget.loggedInUserId.toString(),
          "email": userEmail,
          "order_id": "ORDER-${Random().nextInt(99999)}",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('payment_url')) {
          final paymentUrl = data['payment_url'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(paymentUrl: paymentUrl),
            ),
          );
        } else {
          print("Payment API Error: payment_url not found");
        }
      } else {
        print("Payment API error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error during payment initiation: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveOrderDetails(double totalPrice, double finalTotal) async {
    try {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cartItems;

      List<Map<String, dynamic>> itemsDetails = [];

      cartItems.forEach((key, item) {
        itemsDetails.add({
          "product_id": item['product_id'],
          "item_name": item['name'],
          "quantity": item['quantity'],
          "price": item['price'],
        });
      });

      final response = await http.post(
        Uri.parse("http://10.0.2.2/minoriiproject/payment_success.php"),
        body: {
          "user_id": widget.loggedInUserId.toString(),
          "branch_id": widget.loggedInBranchId.toString(),
          "order_time": DateTime.now().toIso8601String(),
          "bill_number": "BILL-${Random().nextInt(99999)}",
          "total_price": totalPrice.toString(),
          "total_order": cartItems.length.toString(),
          "loyalty_points": "0",
          "remaining_after_loyalty": finalTotal.toString(),
          "subscription_credit_used": subscriptionCredit.toString(),
          "final_total": finalTotal.toString(),
          "delivery_date_time": selectedDateTime?.toIso8601String() ?? '',
          "items": json.encode(itemsDetails),
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          print("Order details saved successfully!");
        } else {
          print("Failed to save order: ${data['message']}");
        }
      } else {
        print("Failed tosave order: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saving order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    double totalPrice = cartItems.values.fold(0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * quantity);
    });

    double remainingAfterLoyalty = max(0, totalPrice - loyaltyPoints);
    double remainingAfterSubscription =
        max(0, remainingAfterLoyalty - subscriptionCredit);
    double finalTotal = max(0, remainingAfterSubscription);

    String orderTime = DateTime.now().toLocal().toString().substring(0, 19);
    String billNumber = "BILL-${Random().nextInt(99999)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Summary'),
        backgroundColor: const Color(0xFFFFDE21),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 251, 235),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Container
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 244, 229),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch Name
                        _buildSection(
                          title: "Branch Name",
                          child: Text(
                            branchName.isEmpty ? "Loading..." : branchName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Order Details
                        _buildSection(
                          title: "Order Details",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date & Time: $orderTime",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Bill No: $billNumber",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Order Items
                        _buildSection(
                          title: "Order Items",
                          child: Table(
                            border: TableBorder.all(color: Colors.grey),
                            children: [
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.yellow[100]),
                                children: [
                                  _tableCell("Item", true),
                                  _tableCell("Quantity", true),
                                  _tableCell("Price", true),
                                ],
                              ),
                              ...cartItems.entries.map(
                                (entry) {
                                  var item = entry.value;
                                  return TableRow(
                                    children: [
                                      _tableCell(item['name']),
                                      _tableCell(item['quantity'].toString()),
                                      _tableCell(item['price'].toString()),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Cost Breakdown
                        _buildSection(
                          title: "Cost Breakdown",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _tableCell(
                                  "Original Cost: \$${totalPrice.toStringAsFixed(2)}"),
                              _tableCell(
                                  "Loyalty Points Used: \$${loyaltyPoints.toStringAsFixed(2)}"),
                              _tableCell(
                                  "Remaining After Loyalty: \$${remainingAfterLoyalty.toStringAsFixed(2)}"),
                              _tableCell(
                                  "Subscription Credit Used: \$${subscriptionCredit.toStringAsFixed(2)}"),
                              _tableCell(
                                  "Final Total: \$${finalTotal.toStringAsFixed(2)}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Delivery Date & Time Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 244, 229),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: "Delivery Date & Time",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _pickDateTime,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFDE21),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: const Text(
                                        'Select Delivery Date & Time'),
                                  ),
                                ),
                              ),
                              if (selectedDateTime != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Selected Date and Time: ${selectedDateTime!.toLocal()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pay Now Button
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedDateTime == null || _isLoading
                          ? null
                          : () {
                              initiatePayment(finalTotal);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDE21),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _tableCell(String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
          fontSize: isHeader ? 18 : 16,
        ),
      ),
    );
  }
}