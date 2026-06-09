import 'package:flutter/material.dart';
import '../../../data/services/api_client.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _apiClient.fetchStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading students: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED Scaffold: AdminLayout already provides it
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Students",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      child: ListTile(
                        title: Text(student['full_name'] ?? 'Unknown'),
                        subtitle: Text(student['email'] ?? 'No email'),
                        trailing: Switch(
                          value:
                              student['is_qualified'] == 1 ||
                              student['is_qualified'] == true,
                          onChanged: (bool newValue) async {
                            setState(() {
                              student['is_qualified'] = newValue ? 1 : 0;
                            });

                            try {
                              await _apiClient.updateStudentStatus(
                                student['id'],
                                newValue,
                              );
                            } catch (e) {
                              setState(() {
                                student['is_qualified'] = newValue ? 0 : 1;
                              });
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to update status"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
