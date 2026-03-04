import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _token = "";

  Future<String?> resumirTexto(String texto) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://api-inference.huggingface.co/models/facebook/bart-large-cnn"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "inputs": texto,
          "parameters": {
            "max_length": 60,
            "min_length": 20
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[0]["summary_text"];
      } else {
        print("Error IA: ${response.body}");
        return null;
      }
    } catch (e) {
      print("EXCEPTION IA: $e");
      return null;
    }
  }
}