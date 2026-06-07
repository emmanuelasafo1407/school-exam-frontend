import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.info)),
            title: const Text("Exam Venue Update"),
            subtitle: const Text("Paper BCE 302 has been moved to Hall B3."),
            trailing: const Text("1h ago", style: TextStyle(fontSize: 10)),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
