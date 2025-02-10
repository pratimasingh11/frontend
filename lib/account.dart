import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aboutus.dart';
import 'profilePage.dart';
import 'contactUs.dart';
import 'dart:convert';
import 'subscriptionPage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Section Widget
class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDarkMode;

  const Section({
    super.key,
    required this.title,
    required this.children,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Column(children: children),
          ],
        ),
      ),
    );
  }
}

// InteractiveTile Widget
class InteractiveTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InteractiveTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class AccountPage extends StatefulWidget {
  final int branchId;
  final int userId;

  const AccountPage({super.key, required this.branchId, required this.userId});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String fullName = "Loading...";
  bool _isDarkMode = false;
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = widget.userId;

    final response = await http.get(Uri.parse('http://10.0.2.2/minoriiproject/account.php?user_id=$userId'));

    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print("Decoded JSON: $data");

        if (data['success']) {
          setState(() {
            fullName = data['full_name'];
            if (data['profile_picture'] != null) {
              String imagePath = data['profile_picture'];
              if (imagePath.startsWith('http')) {
                _profileImageUrl = imagePath;
                _profileImage = null;
              } else {
                _profileImage = File(imagePath);
                _profileImageUrl = null;
              }
            }
          });
        }
      } catch (e) {
        print("JSON decoding error: $e");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _profileImageUrl = null;
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;

    final uri = Uri.parse('http://10.0.2.2/minoriiproject/account.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = widget.userId.toString();
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture',
      _profileImage!.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (jsonResponse['success']) {
      setState(() {
        _profileImageUrl = jsonResponse['profile_picture'];
        _profileImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _isDarkMode ? Colors.black : Colors.orange,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (_profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.person, size: 50, color: Colors.yellow)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, $fullName',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Section(
                    title: 'General',
                    isDarkMode: _isDarkMode,
                    children: [
                      InteractiveTile(
                        icon: Icons.person_outline,
                        text: 'Profile',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(userId: widget.userId),
                          ),
                        ),
                      ),
                      InteractiveTile(
                        icon: Icons.dark_mode_outlined,
                        text: 'Dark Mode',
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Section(
                    title: 'Additional Information',
                    isDarkMode: _isDarkMode,
                    children: [
                      InteractiveTile(
                        icon: Icons.info_outline,
                        text: 'About Us',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutUsPage()),
                        ),
                      ),
                      InteractiveTile(
                        icon: Icons.contact_page_outlined,
                        text: 'Contact Us',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ContactUsPage()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
