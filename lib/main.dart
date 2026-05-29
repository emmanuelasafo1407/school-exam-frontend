import 'package:flutter/material.dart';
import 'services/api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Exam App Connection Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              print("Testing connection to Laravel backend...");
              ApiClient client = ApiClient();
              bool connected = await client.testConnection();

              if (connected) {
                print("🚀 SUCCESS! Flutter talked to Laravel successfully.");
              } else {
                print(
                  "❌ FAILED! Could not reach the server. Check your IP/Host.",
                );
              }
            },
            child: const Text('Test Connection'),
          ),
        ),
      ),
    );
  }
}
