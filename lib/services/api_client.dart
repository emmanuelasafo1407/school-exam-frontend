import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ⚠️ REPLACE THIS IP WITH YOUR CURRENT PC IP FROM IPCONFIG
  final String baseUrl = "http://172.20.10.3:8000/api";

  //  CORRECT: Remove the first async, keep the one after the parameters
  Future<Map<String, dynamic>> registerStudent(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register/student"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      return {
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "body": {"status": "error", "message": e.toString()},
      };
    }
  }
}
