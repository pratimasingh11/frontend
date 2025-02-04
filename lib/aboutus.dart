import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow[700],
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Introduction section
                buildIntroSection(
                  title: 'Introduction',
                  content:
                      'EasyMeals is a modern, user-friendly solution that allows students and faculty members to order food in advance, track orders in real-time, pay bills securely, provide feedback, and utilize smart features like subscription plans, reward points, pre-order options, and inventory tracking.',
                  imagePath: 'assets/intro.jpg',
                  context: context,
                ),
                const SizedBox(height: 20),

                // Zigzag sections
                buildZigzagSection(
                  title: 'Objectives',
                  content:
                      'Develop intuitive user profiles, implement menu listings, integrate secure payment gateways, enable real-time order tracking, and facilitate inventory management for canteen administrators.',
                  imagePath: 'assets/obje.jpg',
                  isImageFirst: true,
                  context: context,
                ),
                const SizedBox(height: 20),

                buildZigzagSection(
                  title: 'Vision',
                  content:
                      'Our vision is to revolutionize the way students, faculty, and canteen administrators interact with on-campus dining services. We aim to create a seamless, intuitive, and technologically advanced canteen management system.',
                  imagePath: 'assets/vision.jpg',
                  isImageFirst: false,
                  context: context,
                ),
                const SizedBox(height: 20),

                buildZigzagSection(
                  title: 'Mission',
                  content:
                      'To provide students, teachers, and staff with a user-friendly, efficient, and innovative platform that simplifies food ordering, payment processes, and inventory management.',
                  imagePath: 'assets/mission4.jpg',
                  isImageFirst: true,
                  context: context,
                ),
                const SizedBox(height: 20),

                buildZigzagSection(
                  title: 'Goals',
                  content:
                      'Facilitate online ordering and payments, enhance order accuracy, and improve customer convenience and satisfaction.',
                  imagePath: 'assets/goals2.jpg',
                  isImageFirst: false,
                  context: context,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Introduction section
  Widget buildIntroSection({
    required String title,
    required String content,
    required String imagePath,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.yellow[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showImageDialog(context, imagePath),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 16.0), // Move image slightly down
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  height: 260, // Increased height
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Zigzag section with improved image alignment
  Widget buildZigzagSection({
    required String title,
    required String content,
    required String imagePath,
    required bool isImageFirst,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImageFirst) buildImage(imagePath, context),
          if (isImageFirst) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          if (!isImageFirst) const SizedBox(width: 16),
          if (!isImageFirst) buildImage(imagePath, context),
        ],
      ),
    );
  }

  // Build image with adjusted size and margin
  Widget buildImage(String imagePath, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0), // Move image slightly down
      child: GestureDetector(
        onTap: () => _showImageDialog(context, imagePath),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            height: 220, // Increased height
            width: 200, // Increased width
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Image popup dialog
  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}