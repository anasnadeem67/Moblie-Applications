import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; 
import 'screens/dashboard_screen.dart'; 

void main() async {
  // Ensures that widget binding is initialized before calling native code like Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initializing Firebase with platform-specific options (Android, iOS, Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Starting the Flutter application
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack Pro',
      debugShowCheckedModeBanner: false, // Disables the debug banner in the top right corner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
        useMaterial3: true, // Enabling Material 3 design system for modern UI components
        textTheme: GoogleFonts.poppinsTextTheme(), // Implementing Poppins font for better typography
      ),
      
      // PERSISTENT AUTHENTICATION LOGIC:
      // StreamBuilder monitors the user's login state in real-time.
      // If a user is already logged in, they are directed to the Dashboard.
      // Otherwise, the app shows the Login Screen.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Displaying a loader while Firebase is checking the authentication status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // User is authenticated, navigate to the Dashboard
          if (snapshot.hasData) {
            return const DashboardScreen();
          }
          
          // No active session found, navigate to the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}