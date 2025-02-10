import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webViewPage.dart';

class CartSummary extends StatefulWidget {
  final int loggedInBranchId;
  final int loggedInUserId;
  final double totalAmount;

  const CartSummary({
    super.key,
    required this.loggedInBranchId,
    required this.loggedInUserId,
    required this.totalAmount,
  });

  @override
  _CartSummaryState createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary> {
  int remainingMeals = 0; // Initialize remainingMeals variable

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

    final cartProvider =
        context.read<CartProvider>(); // Use read to access cart data
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
      Uri.parse('http://10.0.2.2/minoriiproject/subscription.php'),
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

          print("Subscription Credit: ${data['subscription_credit']}");
          print("Remaining Meals: ${data['remaining_meals']}");
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

    if (pickedDate != null) {
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
  }

  Future<void> initiatePayment(double totalAmount) async {
    // Ensure the selected date & time is valid before proceeding
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select delivery date & time")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save order details before payment
    double totalPrice = totalAmount;
    double finalTotal =
        totalAmount; // Here you can calculate the final total based on discounts, etc.
    await saveOrderDetails(totalPrice, finalTotal); // Save order before payment

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

          // Navigate to WebViewPage to display Khalti payment
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

  Widget tableCell(String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(2025),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
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
print("Cart Items: ${json.encode(itemsDetails)}");

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

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        print("Order details saved successfully!");
      } else {
        print("Failed to save order: ${data['message']}");
      }
    } else {
      print("Failed to save order: ${response.statusCode}");
    }
  } catch (e) {
    print("Error saving order: $e");
  }
}



  @override
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
        backgroundColor: Colors.yellow[700],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branchName.isEmpty ? "Loading..." : branchName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Order Details:"),
                  Text("Date & Time: $orderTime"),
                  Text("Bill No: $billNumber"),
                  const SizedBox(height: 16),
                  const Text("Order Items:"),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          tableCell("Item", true),
                          tableCell("Quantity", true),
                          tableCell("Price", true),
                        ],
                      ),
                      ...cartItems.entries.map(
                        (entry) {
                          var item = entry.value;
                          return TableRow(
                            children: [
                              tableCell(item['name']),
                              tableCell(item['quantity'].toString()),
                              tableCell(item['price'].toString()),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Cost Breakdown:"),
                  tableCell(
                      "Original Cost: \$${totalPrice.toStringAsFixed(2)}"),
                  tableCell(
                      "Loyalty Points Used: \$${loyaltyPoints.toStringAsFixed(2)}"),
                  tableCell(
                      "Remaining After Loyalty: \$${remainingAfterLoyalty.toStringAsFixed(2)}"),
                  tableCell(
                      "Subscription Credit Used: \$${subscriptionCredit.toStringAsFixed(2)}"),
                  tableCell("Final Total: \$${finalTotal.toStringAsFixed(2)}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    child: const Text('Select Delivery Date & Time'),
                  ),
                  if (selectedDateTime != null)
                    Text(
                      'Selected Date and Time: ${selectedDateTime!.toLocal()}',
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            initiatePayment(finalTotal);
                          },
                    child: const Text('Pay Now'),
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
}