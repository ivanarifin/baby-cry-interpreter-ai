import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  final String baseUrl;
  final String apiKey;
  final String model;
  final String? oauthKey;

  GeminiService({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.oauthKey,
  });

  Future<String> analyzeCry(File audioFile) async {
    try {
      // Convert audio to Base64
      List<int> audioBytes = await audioFile.readAsBytes();
      String base64Audio = base64Encode(audioBytes);

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          if (oauthKey != null) 'X-OAuth-Key': oauthKey!,
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content": "You are an expert in baby cry analysis. Analyze the provided audio and determine if the baby is hungry, sleepy, uncomfortable, or in pain. Provide a concise explanation and advice for the parents."
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Analyze this baby cry audio."
                },
                {
                  "type": "input_audio",
                  "input_audio": {
                    "data": base64Audio,
                    "format": "wav" // Adjust based on actual recording format
                  }
                }
              ]
            }
          ],
          "response_format": { "type": "json_object" }
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to analyze cry: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
