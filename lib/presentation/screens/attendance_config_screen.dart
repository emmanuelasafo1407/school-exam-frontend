import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'student_verify_details_screen.dart'; // 👈 FIXED: Routes exclusively here

class AttendanceConfigScreen extends StatefulWidget {
  const AttendanceConfigScreen({super.key});

  @override
  State<AttendanceConfigScreen> createState() => _AttendanceConfigScreenState();
}

class _AttendanceConfigScreenState extends State<AttendanceConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hallController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;

  Future<void> _pickDateTime(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      final finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (isStart) {
        _startTime = finalDateTime;
      } else {
        _endTime = finalDateTime;
      }
    });
  }

  void _proceedToScanner() {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Configure session start and end time thresholds!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentVerifyDetailsScreen(
          // 👈 FIXED: Points to the correct constructor
          courseCode: _codeController.text.trim().toUpperCase(),
          courseName: _nameController.text.trim(),
          hall: _hallController.text.trim().toUpperCase(),
          startTime: _startTime!.toIso8601String(),
          endTime: _endTime!.toIso8601String(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configure Exam Session"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: "Course Code (e.g., MATH 101)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Enter target course code" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Course Title (e.g., Engineering Math)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter course title name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hallController,
                decoration: const InputDecoration(
                  labelText: "Examination Room / Hall (e.g., G6)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Map room location index" : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDateTime(true),
                      icon: const Icon(Icons.play_circle, color: Colors.green),
                      label: Text(
                        _startTime == null
                            ? "Set Start Time"
                            : DateFormat('hh:mm a').format(_startTime!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDateTime(false),
                      icon: const Icon(Icons.stop, color: Colors.red),
                      label: Text(
                        _endTime == null
                            ? "Set End Time"
                            : DateFormat('hh:mm a').format(_endTime!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _proceedToScanner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Initialize Attendance Scanner Engine",
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
