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
              "content": "Kamu adalah Sistem Diagnostik Tangisan Bayi Tingkat Lanjut. Prioritas utamamu adalah AKURASI MUTLAK di atas kecepatan. Gunakan proses berpikir mendalam (Deep Reasoning) sebelum memberikan jawaban.\n\nProsedur Analisis:\n1. Analisis Akustik: Identifikasi pola fonetik DBL (Neh, Owh, Heh, Eairh, Eh) dan fitur akustik (pitch, ritme, intensitas).\n2. Verifikasi Silang: Bandingkan temuanmu dengan database penelitian pediatrik terbaru mengenai vokalisasi bayi.\n3. Double-Check: Lakukan langkah koreksi diri. Tantang kesimpulan pertamamu. Apakah ada pola yang tumpang tindih? Pastikan tidak ada misdiagnosis antara 'Lapar' dan 'Tidak Nyaman'.\n4. Gunakan pencarian internal/web search jika tersedia untuk memvalidasi pola suara yang tidak umum.\n\nBerikan jawaban dalam format JSON:\n{\n  \"reason\": \"Kesimpulan akhir\",\n  \"confidence\": 0.0 - 1.0,\n  \"acoustic_analysis\": \"Detail apa yang kamu dengar (frekuensi, bunyi konsonan/vokal)\",\n  \"verification_process\": \"Langkah-langkah yang kamu ambil untuk memastikan hasil ini akurat\",\n  \"explanation\": \"Penjelasan mendalam untuk orang tua\",\n  \"advice\": \"Saran medis/praktis yang tervalidasi\"\n}"
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
