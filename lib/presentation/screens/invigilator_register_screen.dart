import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_client.dart';

class InvigilatorRegisterScreen extends StatefulWidget {
  const InvigilatorRegisterScreen({super.key});

  @override
  State<InvigilatorRegisterScreen> createState() =>
      _InvigilatorRegisterScreenState();
}

class _InvigilatorRegisterScreenState extends State<InvigilatorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _imageFile;
  String? _base64Image;
  bool _isLoading = false;

  // Method to handle picking the physical signature image from gallery/canvas screenshot
  Future<void> _pickSignatureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Maintain sharp lines for signatures rendering
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageFile = File(image.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> registrationData = {
      "full_name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone_number": _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      "password": _passwordController.text,
      "signature_image":
          _base64Image, // 👈 Attached the encoded signature string layer payload
    };

    final result = await _apiClient.registerInvigilator(registrationData);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["statusCode"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["body"]["message"] ?? "Invigilator Registered Successfully!",
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _imageFile = null;
        _base64Image = null;
      });
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["body"]["message"] ?? "Registration failed."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invigilator Registration')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // 👈 SIGNATURE DISPLAY BOX COMPONENT
                    Center(
                      child: GestureDetector(
                        onTap: _pickSignatureImage,
                        child: Container(
                          width: 200,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.blue.shade300,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.draw,
                                      size: 28,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Tap to upload Signature Image",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v!.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Register Invigilator Account',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
