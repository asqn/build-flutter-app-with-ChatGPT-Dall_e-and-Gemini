import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lab33_qnais/secgemini.dart'; 

class GeminiService {
  Future<String> generateGeminiPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.gemini.com/v1/mytrades'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $geminiAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          
        }),
      );

      if (response.statusCode == 200) {
        String result = jsonDecode(response.body)['result'];
        return result;
      } else {
        return 'Erreur de requête Gemini: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erreur de connexion: $e';
    }
  }
}
