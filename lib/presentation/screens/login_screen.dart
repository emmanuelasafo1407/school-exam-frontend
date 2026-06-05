import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_client.dart';
import 'register_gateway_screen.dart';
import 'student_dashboard.dart';
import 'invigilator_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _apiClient.loginUser(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result["statusCode"] == 200) {
      final body = result["body"];
      final token = body["token"];
      final userRole = body["user"]["role"];
      final fullName = body["user"]["full_name"];
      final int userId =
          body["user"]["id"]; // 👈 Extract primary database auto-increment ID integer

      // Save session data locally on the Infinix phone
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'user_id',
        userId,
      ); // 👈 Cache ID to track who marks the attendance logs
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', userRole);
      await prefs.setString('user_name', fullName);

      // Capture the passport image path from the Laravel payload if a student logs in
      if (body["user"]["student_profile"] != null) {
        String rawUrl =
            body["user"]["student_profile"]["passport_picture"] ?? "";
        // Convert 'localhost' to your real computer IP address so your phone can read it over the Wi-Fi loop
        String routingUrl = rawUrl.replaceAll("localhost", "172.20.10.3");
        await prefs.setString('user_passport', routingUrl);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, $fullName!"),
          backgroundColor: Colors.green,
        ),
      );

      // Route cleanly to the correct functional dashboards
      // Route cleanly to the correct functional dashboards by passing runtime state criteria downstream
      if (userRole == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(
              userData:
                  body["user"], // 👈 Passes the core user data map payload down
              token:
                  token, // 👈 Passes the secure Sanctum session token string down
            ),
          ),
        );
      } else if (userRole == 'invigilator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvigilatorDashboard(
              userData:
                  body["user"], // 👈 Passes details down to supervisor views symmetrically
              token: token,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["body"]["message"] ??
                "Login failed. Check your credentials.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Login')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.lock_person, size: 80, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Exam Attendance Manager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterGatewayScreen(),
                          ),
                        );
                      },
                      child: const Text("Don't have an account? Register here"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
