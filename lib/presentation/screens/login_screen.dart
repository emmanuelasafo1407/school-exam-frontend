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
      final String token = body["token"];
      final String role = body["user"]["role"] ?? "student";
      final String fullName = body["user"]["full_name"] ?? "User";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString('user_name', fullName);

      if (role == 'student') {
        final Map<String, dynamic> studentProfile = {
          "name": fullName,
          "index_number":
              body["user"]["student_profile"]?["student_id_number"] ?? "N/A",
          "level": body["user"]["student_profile"]?["level"] ?? "300",
          "program": body["user"]["student_profile"]?["program"] ?? "N/A",
          "session": body["user"]["student_profile"]?["session"] ?? "Morning",
          "passport_picture":
              body["user"]["student_profile"]?["passport_picture"],
        };

        final List<Map<String, dynamic>> rawSemesterExams =
            body["exams"] != null
            ? List<Map<String, dynamic>>.from(body["exams"])
            : [];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(
              studentProfile: studentProfile,
              rawSemesterExams: rawSemesterExams,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvigilatorDashboard(userData: body["user"], token: token),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["body"]["message"] ?? "Login failed."),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_person, size: 80, color: Colors.blue),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
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
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterGatewayScreen(),
                        ),
                      ),
                      child: const Text("Register here"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
