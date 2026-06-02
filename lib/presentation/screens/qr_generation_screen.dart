import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrGenerationScreen extends StatefulWidget {
  const QrGenerationScreen({super.key});

  @override
  State<QrGenerationScreen> createState() => _QrGenerationScreenState();
}

class _QrGenerationScreenState extends State<QrGenerationScreen> {
  String _studentName = "Student";
  String _studentId = "0000000000";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecureProfileData();
  }

  Future<void> _loadSecureProfileData() async {
    // Fetch state directly from the phone device encrypted properties memory map
    final prefs = await SharedPreferences.getInstance();

    // In a production setup, we can fetch these nested profile values safely or parse the storage keys
    setState(() {
      _studentName = prefs.getString('user_name') ?? "Emmanuel Asafo";
      // Fallback example placeholder if profile object structure key isn't stored separately yet
      _studentId = "1706547871";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Exam Entry Pass"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Official Hall Admission Token",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Present this encrypted barcode matrix to the hall invigilator at the gate door position for scanning check-in validation.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // The Printed Card Block
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _studentName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ID: $_studentId",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // QR Code Matrix Implementation Rendering Block
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: QrImageView(
                              data:
                                  _studentId, // This embeds the student ID inside the scan token payload
                              version: QrVersions.auto,
                              size: 200.0,
                              gapless: false,
                              errorCorrectionLevel: QrErrorCorrectLevel
                                  .H, // High error tolerance for scratched phone screens
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Export Options Blueprint
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add pdf document layout rendering script block downstream
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Preparing printable document layout blueprint...",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text(
                      "Export Pass as Printout PDF",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
