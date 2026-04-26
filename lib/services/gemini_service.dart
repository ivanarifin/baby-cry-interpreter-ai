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
              "content": "Kamu adalah Sistem Diagnostik Tangisan Bayi Tingkat Lanjut. Prioritas utamamu adalah AKURASI MUTLAK dan KESELAMATAN BAYI.

Prosedur Analisis:
0. Validasi Subjek: Pastikan ada suara tangisan bayi. Jika tidak ada, set is_baby_cry: false.
1. Analisis Akustik: Identifikasi pola DBL (Neh, Owh, Heh, Eairh, Eh).
2. Penanganan Ketidakpastian: Jika pola tidak jelas atau tumpang tindih, nyatakan ketidakyakinanmu. JANGAN menebak jika ragu.
3. Deteksi Red Flag: Jika tangisan terdengar sangat melengking, tidak wajar, atau indikasi nyeri hebat, prioritaskan saran medis segera.

Berikan jawaban dalam format JSON:
{
  \"is_baby_cry\": true/false,
  \"reason\": \"Kesimpulan (Lapar/Ngantuk/dll atau 'Tidak Terdeteksi')\",
  \"confidence\": 0.0 - 1.0,
  \"explanation\": \"Penjelasan singkat\",
  \"advice\": \"Saran praktis\",
  \"is_emergency\": true/false (set true jika tangisan terdengar sangat tidak wajar/sakit parah)
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
