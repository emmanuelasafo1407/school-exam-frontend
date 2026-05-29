import 'package:http/http.dart' as http;

class ApiClient {
  // CRITICAL: Replace '192.168.1.X' with your computer's actual local IPv4 address.
  // Do NOT use 'localhost' or '127.0.0.1' because the phone/emulator will look inside itself.
  static const String baseUrl = 'http://172.20.10.3:8000/api'; 

  final http.Client _client = http.Client();

  // A quick method to test if the Flutter app can physically talk to Laravel
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/user'));
      // If we get any response back (even a 401 Unauthenticated), the network pipe is working!
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      print("Network Connection Error: $e");
      return false;
    }
  }
}