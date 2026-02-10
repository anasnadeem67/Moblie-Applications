import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart'; 
import 'dashboard_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to capture user input for authentication
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Method to handle the authentication logic using Firebase
  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Attempting to sign in the user through the AuthService
    var user = await _authService.login(_emailController.text.trim(), _passwordController.text.trim());
    
    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        // Navigating to the Dashboard upon successful authentication
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        // Displaying an error message if the login credentials are incorrect
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed: Check your email/password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "FinTrack Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
            ),
            const SizedBox(height: 40),
            
            // Input field for the user's registered email address
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            // Input field for the user's secure password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            
            // Displaying a progress indicator while authentication is in progress
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _handleLogin,
                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
            const SizedBox(height: 10),
            
            // Navigation link for new users to register an account
            TextButton(
              onPressed: () {
                // Navigating to the SignupScreen to create a new business account
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFF673AB7))),
            ),
          ],
        ),
      ),
    );
  }
}