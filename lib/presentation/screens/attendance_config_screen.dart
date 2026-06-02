import 'package:flutter/material.dart';
import 'scanner_view_screen.dart'; // We will create this next

class AttendanceConfigScreen extends StatefulWidget {
  const AttendanceConfigScreen({super.key});

  @override
  State<AttendanceConfigScreen> createState() => _AttendanceConfigScreenState();
}

class _AttendanceConfigScreenState extends State<AttendanceConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();
  final TextEditingController _hallController = TextEditingController();
  final TextEditingController _coInvigilatorController =
      TextEditingController();

  void _proceedToScanner() async {
    if (!_formKey.currentState!.validate()) return;

    // 👈 UPDATED: Await navigation completion to watch for systemic completion codes
    final sessionStatus = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerViewScreen(
          courseCode: _courseCodeController.text.trim(),
          courseName: _courseNameController.text.trim(),
          hall: _hallController.text.trim(),
        ),
      ),
    );

    // If session returns with exit confirmation target, break down the config screen and pop straight back to home dashboard
    if (sessionStatus == "EXIT_SESSION" || !mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configure Exam Session")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lecturerController,
                decoration: const InputDecoration(
                  labelText: 'Lecturer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hallController,
                decoration: const InputDecoration(
                  labelText: 'Examination Hall',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coInvigilatorController,
                decoration: const InputDecoration(
                  labelText: 'Add Co-Invigilators (Optional)',
                  hintText: 'Name 1, Name 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _proceedToScanner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Continue to Take Attendance",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
