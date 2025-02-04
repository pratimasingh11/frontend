import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'profilePage.dart';
import 'contactUs.dart';
import 'subscriptionPage.dart';

class AccountPage extends StatefulWidget {
  final int branchId; // Add this to accept branchId
  final int userId; // Add this to accept userId

  // Modify the constructor to accept these parameters
  const AccountPage({super.key, required this.branchId, required this.userId});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isDarkMode = false; // State to manage dark mode toggle

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: _isDarkMode
                ? Colors.black
                : const Color.fromARGB(255, 205, 95, 6),
            flexibleSpace: Container(
              color: _isDarkMode ? Colors.grey[850] : const Color(0xFFFFC400),
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50,
                        color: _isDarkMode ? Colors.black : Colors.yellow),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: ${widget.userId}', // Displaying userId
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Branch ID: ${widget.branchId}', // Displaying branchId
                    style: TextStyle(
                      color: _isDarkMode ? Colors.grey : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // General Section
                Section(
                  title: 'General',
                  isDarkMode: _isDarkMode, // Pass the dark mode flag
                  children: [
                    InteractiveTile(
                      icon: Icons.person_outline,
                      text: 'Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        );
                      },
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
                    InteractiveTile(
                      icon: Icons.list_alt,
                      text: 'Order List',
                      onTap: () {},
                    ),
                  ],
                ),

                // Promotional Activity Section
                Section(
                  title: 'Promotional Activity',
                  isDarkMode: _isDarkMode, // Pass the dark mode flag
                  children: [
                    InteractiveTile(
                      icon: Icons.star_border,
                      text: 'Loyalty Points',
                      onTap: () {},
                    ),
                    InteractiveTile(
                      icon: Icons.star_border,
                      text: 'Loyalty Points',
                      onTap: () {},
                    ),
             InteractiveTile(
  icon: Icons.subscriptions,
  text: 'Subscription',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPage(userId: widget.userId), // Pass userId
      ),
    );
  },
),

                  ],
                ),

                // Help and Support Section
                Section(
                  title: 'Help and Support',
                  isDarkMode: _isDarkMode, // Pass the dark mode flag
                  children: [
                    InteractiveTile(
                      icon: Icons.info_outline,
                      text: 'About Us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsPage()),
                        );
                      },
                    ),
                    InteractiveTile(
                      icon: Icons.contact_page_outlined,
                      text: 'Contact Information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactUsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            // Handle bottom navigation bar taps here if needed
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  final List<Widget> children;const Section(
      {super.key,
      required this.title,
      required this.children,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[850]
            : Colors.white, // Background color based on dark mode
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Text color based on dark mode
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class InteractiveTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InteractiveTile({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}