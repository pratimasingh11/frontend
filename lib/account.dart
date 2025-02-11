import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aboutUs.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 24, color: Colors.amber),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

  final response = await http.get(Uri.parse(
      'http://10.0.2.2/minoriiproject/account.php?user_id=$userId'));

  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body);
      print("Decoded JSON: $data");

      if (data['success']) {
        setState(() {
          fullName = data['full_name'];
          _profileImageUrl = data['profile_picture'] ?? prefs.getString('profile_picture_url');
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture_url', jsonResponse['profile_picture']);

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
          backgroundColor: _isDarkMode
              ? Colors.black
              : const Color.fromARGB(255, 253, 228, 6),
          title: const Text('Account'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
        ),
        backgroundColor: _isDarkMode
            ? Colors.grey[850]
            : const Color.fromARGB(255, 252, 248, 211),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.amber.withOpacity(0.2),
                            child: _profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _profileImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (_profileImageUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _profileImageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.person,
                                        size: 40, color: Colors.amber)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              fullName,
                              style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // General Section
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
                            builder: (context) =>
                                ProfilePage(userId: widget.userId),
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
                          activeColor: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Promotional Information Section
                  Section(
                    title: 'Promotional Information',
                    isDarkMode: _isDarkMode,
                    children: [
                      InteractiveTile(
                        icon: Icons.person_outline,
                        text: 'Subscription',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SubscriptionPage(userId: widget.userId),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Information Section
                  Section(
                    title: 'Additional Information',
                    isDarkMode: _isDarkMode,
                    children: [
                      InteractiveTile(
                        icon: Icons.info_outline,
                        text: 'About Us',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsPage()),
                        ),
                      ),
                      InteractiveTile(
                        icon: Icons.contact_page_outlined,
                        text: 'Contact Us',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactUsPage()),
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