import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

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

  // Controllers for change password
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  // Fetch user profile data
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
              'fullname': data['fullname'] ?? 'Unknown User',
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

  // Function to change password
  Future<void> changePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('New password and confirmation do not match.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2/minoriiproject/changePassword.php'),
        body: {
          'user_id': widget.userId.toString(),
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Your password has been changed.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to change password: ${data['error']}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        print('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to delete account
  Future<void> deleteAccount() async {
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2/minoriiproject/deleteAccount.php'),
        body: {'user_id': widget.userId.toString()},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.pushReplacementNamed(
              context, '/login'); // Redirect to login page
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Account Deleted'),
              content:
                  const Text('Your account has been successfully deleted.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete account: ${data['error']}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        print('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 253, 228, 6),
      ),
      backgroundColor: Colors.yellow[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height: 30), // Space between AppBar and profile section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: userProfile['profilePicture'].isNotEmpty
                      ? NetworkImage(
                          'http://10.0.2.2/minoriiproject/uploads/${userProfile['profilePicture']}')
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 16),
                Text(
                  userProfile['fullname'].isNotEmpty? userProfile['fullname']
                      : 'Loading...',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
                height: 30), // Space between profile section and Total Orders
            // Total Orders Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                border: Border.all(color: Colors.yellow.shade700, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.yellow[700]),
                  const SizedBox(width: 16),
                  Text('Total Orders: ${userProfile['totalOrder']}'),
                ],
              ),
            ),
            const SizedBox(
                height: 30), // Space between Total Orders and buttons
            // Buttons Row
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              const Color.fromARGB(255, 246, 243, 186),
                          title: const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 20, // Increase font size
                              fontWeight: FontWeight.bold,
                              color: Colors.orange, // Set title text color
                            ),
                          ),
                          content: SizedBox(
                            height: 200, // Adjust the height here
                            child: Column(
                              children: [
                                TextField(
                                  controller: _currentPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Current Password',
                                  ),
                                ),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'New Password',
                                  ),
                                ),
                                TextField(
                                  controller: _confirmNewPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm New Password',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                changePassword();
                                Navigator.pop(context);
                              },
                              child: const Text('Change'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 228, 6),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Change Password'),
                ),
                const SizedBox(width: 50), // Space between buttons
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                deleteAccount();
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 239, 36, 36),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}