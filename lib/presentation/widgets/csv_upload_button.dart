import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/services/api_client.dart';

class CsvUploadButton extends StatelessWidget {
  // 1. Non-const constructor required because _apiClient is initialized here
  CsvUploadButton({super.key});

  final ApiClient _apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text("Bulk Upload Students"),
      onPressed: () async {
        // 2. Using the standard pickFiles() method directly
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        // 3. Robust null-safety check: verifies file selection exists and has a path
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.path != null) {
          final String path = result.files.single.path!;

          // 4. Perform the upload and capture the response
          final response = await _apiClient.uploadStudentCsv(path);

          // 5. Guard: ensure the widget is still in the tree after the async gap
          if (!context.mounted) return;

          // 6. Provide user feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.containsKey('message')
                    ? "Upload result: ${response['message']}"
                    : "Upload completed successfully",
              ),
            ),
          );
        }
      },
    );
  }
}
