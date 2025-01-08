import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

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
            backgroundColor:
                _isDarkMode ? Colors.black : const Color.fromARGB(255, 205, 95, 6),
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
                    'User',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Login to view all the features',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // General Section
              Section(title: 'General', children: [
                ListTile(
  leading: const Icon(Icons.person_outline),
  title: const Text('Profile'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileApp()),
    );
  },
),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value; // Toggle dark mode
                    });
                  },
                ),
              ]),
              // Promotional Activity Section
              Section(title: 'Promotional Activity', children: [
                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: const Text('Loyalty Points'),
                  onTap: () {},
                ),
              ]),
              // Help and Support Section
              Section(title: 'Help and Support', children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_page_outlined),
                  title: const Text('Contact Information'),
                  onTap: () {
                    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactUsPage()),
      );
    },
  ),
]),
            ],
          ),
        ),
          
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const Section({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}




class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Profile Info Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFDE9E9), // Light pink background
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 15),
                const Text(
                  "Srijana",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Icon(Icons.edit, color: Colors.black),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Loyalty Points & Total Order Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoCard(
                  title: "Loyalty Points",
                  value: "0",
                  icon: Icons.star_border,
                  color: Colors.orange,
                ),
                InfoCard(
                  title: "Total Order",
                  value: "0",
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Delete Account Button with Popup Dialog
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: GestureDetector(
              onTap: () => _showDeleteAccountPopup(context), // Show the popup
              child: const ProfileOption(
                icon: Icons.delete,
                title: "Delete Account",
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),

          const Spacer(),

          // App Version
          const Text(
            "Version: 7.9",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Function to display the delete confirmation popup
  void _showDeleteAccountPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 60, color: Colors.black),
              const SizedBox(height: 10),
              const Text(
                "Delete Your Account?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "You will not be able to recover your data again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close popup
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Simulate deleting account (e.g., remove data, update server, etc.)
                      await _deleteAccount(); // Call the delete account function
                    
                      // Close the dialog
                      Navigator.of(context).pop();
                    
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account Deleted Successfully"),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Remove"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Simulate account deletion logic (e.g., removing from database, clearing local storage, etc.)
  Future<void> _deleteAccount() async {
    // This is a placeholder for actual account deletion logic.
    // Here you can add the code to delete the user's data, such as:
    // - Remove user data from local storage (e.g., using SharedPreferences)
    // - Make an API call to delete the account from the backend
    // - Remove any session or authentication tokens

    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay (e.g., network call)
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final double fontSize;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade100),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.black, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}




              
                  

          
      

        
   
      


class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.yellow,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For any questions or concerns regarding our app, please contact EasyMeals at:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Email: easy.meals@gmail.com',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Phone Numbers:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• 9810515711\n• 9803257815\n• 9703944417\n• 9864111755',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Feel free to reach out to us!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.yellow,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introduction',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'EasyMeals is a modern, user-friendly solution that allows students and faculty members to order food in advance, track orders in real-time, pay bills securely, provide feedback, and utilize smart features like subscription plans, reward points, pre-order options, and inventory tracking. Our mission is to bridge the gap between traditional canteen operations and the technological expectations of today’s students and staff while simplifying canteen management for administrators.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Vision',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our vision is to revolutionize the way students, faculty, and canteen administrators interact with on-campus dining services. We aim to create a seamless, intuitive, and technologically advanced canteen management system that enhances user experience, reduces operational inefficiencies, and supports sustainability efforts.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Mission',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our mission is to provide students, teachers, and staff with a user-friendly, efficient, and innovative platform that simplifies food ordering, payment processes, and inventory management. Through the integration of smart features, data-driven insights, and a robust mobile application, we strive to improve operational processes for canteen administrators while creating a convenient, efficient, and sustainable dining experience for every user.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Objectives',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our objectives align with our mission to streamline canteen management while enhancing user convenience and operational transparency:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Develop intuitive user profiles to save payment preferences and dietary choices.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Implement menu listings with search capabilities, allowing users to view and locate desired food items easily.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Integrate secure payment gateway options to ensure seamless and secure transactions.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Enable real-time order placement and tracking, reducing long waiting times.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Facilitate inventory management for canteen administrators to minimize wastage and ensure optimal stock availability.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Introduce subscription models, smart tables, and reward programs to provide added value and convenience to users.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Incorporate a feedback and ratings system to continuously enhance service quality.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Optimize resource usage and support sustainability goals by reducing the reliance on paper-based processes.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Goals',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'To achieve our mission and objectives, we have outlined the following goals:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Facilitate online ordering and payment processes to save time and improve accuracy.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Enhance order accuracy and operational efficiency by reducing human error through automated processes.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Improve customer convenience and satisfaction by offering intuitive and flexible features.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '• Empower users to share feedback and ratings, enabling continuous improvement and transparency.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'With EasyMeals, we aim to empower educational institutions with operational tools, simplify everyday dining processes, and foster a sustainable, data-driven, and user-centric canteen management experience.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 