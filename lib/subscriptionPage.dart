import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionPage extends StatefulWidget {
  final int userId; // Accept userId

  const SubscriptionPage({super.key, required this.userId});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int? _subscribedPlanId;

  @override
  void initState() {
    super.initState();
    _fetchUserSubscription();
  }

  // Fetch the current subscription status of the user
  Future<void> _fetchUserSubscription() async {
    final url = Uri.parse(
        'http://10.0.2.2/minoriiproject/subscription.php?user_id=${widget.userId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            _subscribedPlanId = responseData['subscription_id'];
          });
        } else {
          setState(() {
            _subscribedPlanId = null; // User is not subscribed
          });
        }
      }
    } catch (e) {
      print("Error fetching subscription: $e");
    }
  }

  // Subscribe user to a plan
  Future<void> _subscribeUser(String planName) async {
    final subscriptionId = _getSubscriptionId(planName);
    DateTime now = DateTime.now();
    DateTime endDate = now.add(const Duration(days: 30));

    bool success =
        await _subscribeUserToPlan(widget.userId, subscriptionId, now, endDate);

    if (success) {
      setState(() {
        _subscribedPlanId =
            subscriptionId; // Update UI to show the user is subscribed
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already subscribed.')),
      );
    }
  }

  // Get subscription ID based on the plan name
  int _getSubscriptionId(String planName) {
    switch (planName) {
      case "Basic":
        return 1;
      case "Premium":
        return 2;
      case "Custom":
        return 3;
      default:
        return 0;
    }
  }

  // Subscribe user to a plan
  Future<bool> _subscribeUserToPlan(int userId, int subscriptionId,
      DateTime startDate, DateTime endDate) async {
    final url = Uri.parse('http://10.0.2.2/minoriiproject/subscription.php');

    final Map<String, dynamic> bodyData = {
      'user_id': userId,
      'subscription_id': subscriptionId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'active',
    };

    print("Sending request to: $url");
    print("Request Body: ${jsonEncode(bodyData)}");

    try {
      final response = await http.post(
        url,
        body: jsonEncode(bodyData),
        headers: {'Content-Type': 'application/json'},
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'];
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: const Color.fromARGB(255, 253, 228, 6),
      ),
      backgroundColor: const Color.fromARGB(255, 238, 233, 187),
      body: ListView(
        children: [
          SubscriptionCard(
            planName: "Basic",
            price: 4000,
            mealsPerMonth: 20,
            sweets: 0,
            drinks: 0,
            isSubscribed: _subscribedPlanId == 1,
            onSubscribe: () => _subscribeUser("Basic"),
          ),
          SubscriptionCard(
            planName: "Premium",
            price: 5000,
            mealsPerMonth: 29,
            sweets: 0,
            drinks: 0,
            isSubscribed: _subscribedPlanId == 2,
            onSubscribe: () => _subscribeUser("Premium"),
          ),
          SubscriptionCard(
            planName: "Custom",
            price: 6000,
            mealsPerMonth: 35,
            sweets: 2,
            drinks: 3,
            isSubscribed: _subscribedPlanId == 3,
            onSubscribe: () => _subscribeUser("Custom"),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final double price;
  final int mealsPerMonth;
  final int sweets;
  final int drinks;
  final bool isSubscribed;
  final VoidCallback onSubscribe;

  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.price,
    required this.mealsPerMonth,
    required this.sweets,
    required this.drinks,
    required this.isSubscribed,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5, // Add some elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // Add padding inside the container
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Add border here
            color: Colors.orange, // Border color
            width: 2, // Border width
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: const TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10), // Add vertical space
            Text(
              "Price: \$${price.toString()} per month",
              style: const TextStyle(
                fontSize: 18, // Increased font size
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8), // Add vertical space
            Text(
              "Meals: $mealsPerMonth meals/month",
              style: const TextStyle(
                fontSize: 18, // Increased font size
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8), // Add vertical space
            Text(
              "Sweets: $sweets",
              style: const TextStyle(
                fontSize: 18, // Increased font size
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8), // Add vertical space
            Text(
              "Drinks: $drinks",
              style: const TextStyle(
                fontSize: 18, // Increased fontsize
                color: Colors.black,
              ),
            ),
            // const SizedBox(height: 5), // Add vertical space
            Center(
              child: ElevatedButton(
                onPressed: isSubscribed ? null : onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubscribed ? Colors.grey : Colors.yellow,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded button
                  ),
                ),
                child: Text(
                  isSubscribed ? 'Already Subscribed' : 'Subscribe',
                  style: const TextStyle(
                    fontSize: 18, // Increased font size
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}