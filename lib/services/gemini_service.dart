import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  final String baseUrl;
  final String apiKey;
  final String model;

  GeminiService({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  Future<String> analyzeCry(File audioFile) async {
    try {
      List<int> audioBytes = await audioFile.readAsBytes();
      String base64Audio = base64Encode(audioBytes);

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content": """You are a professional Infant Cry Diagnostic System. Your objective is to provide objective, clinical-grade analysis of infant vocalizations based on established pediatric research and acoustic patterns. Maintain a strictly professional and formal tone. Avoid informal language or personal addresses.

Analysis Protocol:
1. Subject Verification: Confirm the presence of infant crying. If absent, set 'is_baby_cry' to false.
2. Acoustic Pattern Recognition: Identify specific phonetic markers (e.g., DBL patterns: Neh, Owh, Heh, Eairh, Eh) and acoustic features (frequency, rhythm, intensity).
3. Diagnostic Confidence: Provide a confidence score. If patterns are ambiguous, explicitly state the uncertainty. Do not provide speculative diagnoses.
4. Criticality Assessment: Identify high-intensity or abnormal acoustic markers that may indicate severe distress or medical urgency.

Output Format (JSON):
{
  "is_baby_cry": boolean,
  "reason": "Primary classification (e.g., Hunger, Fatigue, Discomfort, or Undetermined)",
  "confidence": float (0.0 - 1.0),
  "acoustic_analysis": "Technical summary of identified acoustic markers",
  "explanation": "Objective explanation of the findings",
  "advice": "Standard pediatric recommendations for the identified state",
  "is_emergency": boolean
}"""
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Initiate diagnostic analysis on the provided audio sample."
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
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return 'System Error: $e';
    }
  }
}
