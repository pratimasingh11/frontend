import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RatingPage extends StatefulWidget {
  final int loggedInUserId;

  const RatingPage({super.key, required this.loggedInUserId});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  void _submitRating(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/minoriiproject/submitRating.php'),
        body: {
          'user_id': widget.loggedInUserId.toString(),
          'product_id': productId.toString(),
          'rating': _rating.toString(),
        },
      );

      print(
          "Response status code: ${response.statusCode}"); // Debug: Log status code
      print("Response body: ${response.body}"); // Debug: Log response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating submitted successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to submit rating: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to submit rating: Invalid response (${response.statusCode})')),
        );
      }
    } catch (e) {
      print("Error submitting rating: $e"); // Debug: Log any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('How would you rate this product?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            ElevatedButton(
              onPressed: () {
                _submitRating(1); // Replace with actual product ID
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}