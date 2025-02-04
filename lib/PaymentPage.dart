import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Dummy payment details
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  // Function to simulate the payment process
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true; // Show loading
    });

    // Simulating a delay for payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false; // Hide loading
    });

    // Show a success message after payment
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Text(
              'Payment of \$${_amountController.text} has been processed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to simulate payment failure
  Future<void> _paymentFailed() async {
    setState(() {
      _isProcessing = true; // Show loading
    });

    // Simulating a delay for payment failure
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false; // Hide loading
    });

    // Show a failure message after payment attempt
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Failed'),
          content: const Text(
              'Payment could not be processed. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
                hintText: 'e.g., 100.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null // Disable button while processing
                  : () {
                      final amount = _amountController.text;
                      if (amount.isNotEmpty) {
                        _processPayment(); // Process the payment
                      } else {
                        _paymentFailed(); // Simulate failure if no amount is entered
                      }
                    },
              child: _isProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white) // Show loading spinner
                  : const Text('Pay Now'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null // Disable button while processing
                  : () {
                      _paymentFailed(); // Simulate payment failure
                    },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              child: _isProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white) // Show loading spinner
                  : const Text('Fail Payment'),
            ),
          ],
        ),
      ),
    );
  }
}