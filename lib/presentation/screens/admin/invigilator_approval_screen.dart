import 'package:flutter/material.dart';
import '../../../data/services/api_client.dart';

class InvigilatorApprovalScreen extends StatefulWidget {
  const InvigilatorApprovalScreen({super.key});

  @override
  State<InvigilatorApprovalScreen> createState() =>
      _InvigilatorApprovalScreenState();
}

class _InvigilatorApprovalScreenState extends State<InvigilatorApprovalScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _invigilators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiClient.fetchPendingInvigilators();
      setState(() => _invigilators = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approve Invigilators")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _invigilators.length,
              itemBuilder: (context, index) {
                final inv = _invigilators[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(inv['user']['full_name']),
                    subtitle: Text(
                      "Staff ID: ${inv['staff_id']} | Email: ${inv['user']['email']}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await _apiClient.verifyInvigilator(inv['id']);
                        _loadPending(); // Refresh list after verification
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
