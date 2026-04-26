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
              "content": "You are an Advanced Infant Cry Diagnostic System. Your primary priorities are ABSOLUTE ACCURACY and INFANT SAFETY.

Analysis Procedure:
0. Subject Validation: Ensure there is a baby crying sound. If not, set is_baby_cry: false.
1. Acoustic Analysis: Identify DBL patterns (Neh, Owh, Heh, Eairh, Eh).
2. Uncertainty Handling: If patterns are unclear or overlapping, state your uncertainty. DO NOT guess if unsure.
3. Red Flag Detection: If the cry sounds unusually high-pitched, unnatural, or indicates intense pain, prioritize immediate medical advice.

Provide the answer in a clean JSON format:
{
  \"is_baby_cry\": true/false,
  \"reason\": \"Conclusion (Hungry/Sleepy/etc or 'Not Detected')\",
  \"confidence\": 0.0 - 1.0,
  \"explanation\": \"Brief explanation of the acoustic findings\",
  \"advice\": \"Practical advice for parents\",
  \"is_emergency\": true/false (set true if the cry sounds highly unusual or indicates severe pain)
}"
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Lakukan analisis mendalam dan verifikasi pada audio tangisan bayi ini. Utamakan akurasi."
                },
                {
                  "type": "input_audio",
                  "input_audio": {
                    "data": base64Audio,
                    "format": "wav"
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
