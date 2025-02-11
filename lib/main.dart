import 'package:flutter/material.dart';
import 'providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 's_login_page.dart'; 
import 's_signup_page.dart'; 
 import 'signup_page.dart';
 import 'login_page.dart';
 import 'sAdmin_login.dart';
 import 'sAdmin_signup.dart';
 import 'sAdmin_dashboard.dart';
 import 'admin_login.dart';
 import 'admin_dashboard.dart';
import 'admin_signup.dart';
import 'home_page.dart';
 

// // // // // seller side coding
// void main() {
//   runApp(MyApp()); // Pass MyApp as an argument
// }

// class MyApp extends StatelessWidget {
//   // const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Easy Meals',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//       ),


    
//       initialRoute: '/s_signup_page',  // Start with the signup page
//       routes: {
//         '/s_signup_page': (context) =>  const s_SignUpScreen(),
//         '/s_login_page': (context) => const s_LoginScreen (),
    
//       },
//           );
//   }
// }



// // user side 
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // Provide CartProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Meals',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/signup_page',
      routes: {
        '/signup_page': (context) => const SignUpScreen(),
        '/login_page': (context) => const LoginScreen(),
      },
    );
  }
}



// super admin side
// void main() {
//   runApp(MyApp()); // Pass MyApp as an argument
// }

// class MyApp extends StatelessWidget {
//   // const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Easy Meals',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//       ),
//       initialRoute: '/sAdmin_signup',  // Start with the signup page
//       routes: {
//         '/sAdmin_signup': (context) =>  const sadmin_SignUpScreen(),
//         '/sAdmin_login': (context) => const sadmin_LoginScreen (),
//         '/sAdmin_dashboard': (context) => const SuperAdminDashboard(),
//       },
//           );
//   }
// }


// admin side
// void main() {
//   runApp(MyApp()); // Pass MyApp as an argument
// }

// class MyApp extends StatelessWidget {
//   // const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Easy Meals',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//       ),
//  initialRoute: '/admin_signup',
//       routes: {
//         '/admin_signup': (context) => const AdminSignUpScreen(),       
//       },
//           );
//   }
// }