import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage(
      {super.key, required this.userId}); // Constructor to receive userId

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userProfile = {
    'fullname': '',
    'profilePicture': '',
    'totalOrder': 0,
    'notifications': {
      'changePassword': true,
      'deleteAccount': false,
    },
  };

  Future<void> fetchUserProfile() async {
    try {
      var client = http.Client();
      var response = await client.get(
        Uri.parse(
            'http://10.0.2.2/minoriiproject/profilePage.php?user_id=${widget.userId}'),
        headers: {'Accept': 'application/json'},
      );

      print('Response body: ${response.body}'); // Debugging API response

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data.containsKey('error')) {
          print('Error: ${data['error']}');
        } else {
          setState(() {
            userProfile = {
              'fullname': data['fullname'] ?? 'Unknown User', // Default if null
              'profilePicture': data['profilePicture'] ?? '',
              'totalOrder': data['totalOrder'] ?? 0,
              'notifications': data['notifications'] ??
                  {
                    'changePassword': true,
                    'deleteAccount': false,
                  },
            };
          });
        }
      } else {
        print('Failed to fetch profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
  radius: 30,
  backgroundImage: userProfile['profilePicture'].isNotEmpty
      ? NetworkImage('http://10.0.2.2/minoriiproject/uploads/${userProfile['profilePicture']}')
      : const AssetImage('assets/default_profile.png') as ImageProvider,
),

                const SizedBox(width: 16),
                Text(
                  userProfile['fullname'].isNotEmpty
                      ? userProfile['fullname']
                      : 'Loading...',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Total Orders Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow.shade100, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.yellow.shade700),
                  const SizedBox(width: 16),
                  Text('Total Orders: ${userProfile['totalOrder']}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Notifications Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow.shade100, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.yellow.shade700),
                        const SizedBox(width: 10),
                        const Text('Change Password'),
                      ],
                    ),
                    value: userProfile['notifications']['changePassword'],
                    onChanged: (bool? value) {
                      setState(() {
                        userProfile['notifications']['changePassword'] = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.yellow.shade700),
                        const SizedBox(width: 10),
                        const Text('Delete Account'),
                      ],
                    ),
                    value: userProfile['notifications']['deleteAccount'],
                    onChanged: (bool? value) {
                      setState(() {
                        userProfile['notifications']['deleteAccount'] = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}