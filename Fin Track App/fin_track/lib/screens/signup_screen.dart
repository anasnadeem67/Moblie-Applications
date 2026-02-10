import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Text editing controllers to manage and retrieve user input for registration
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Setting PKR as the default base currency for new users in the backend
  final String _defaultCurrency = 'PKR';

  // Function to handle the business account registration process
  void _handleSignup() async {
    // Validating that all mandatory fields are filled before proceeding
    if (_nameController.text.trim().isEmpty || 
        _businessController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Registering the user and storing extended business profile details in Firestore
    var user = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      businessName: _businessController.text.trim(),
      phone: _phoneController.text.trim(),
      baseCurrency: _defaultCurrency,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      // Success: Inform the user and navigate back to the login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully! Please Login.")),
      );
      Navigator.pop(context); 
    } else {
      // Failure: Alert the user regarding network or credential issues
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Failed: Check your network or email address.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Business Account")),
      body: SingleChildScrollView( 
        // SingleChildScrollView ensures the UI remains accessible when the keyboard appears
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User's Legal Full Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Registered Business or Shop name for professional reporting
            TextField(
              controller: _businessController,
              decoration: const InputDecoration(
                labelText: 'Business / Shop Name', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),

            // Official Business Contact Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            // Business Email Address for account recovery and login
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Secure account password input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (min 6 chars)', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 32),

            // Displays a loading indicator or the action button based on the state
            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _handleSignup,
                    child: const Text(
                      "Create Account", 
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Releasing memory by disposing controllers when the screen is removed from the widget tree
    _nameController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}