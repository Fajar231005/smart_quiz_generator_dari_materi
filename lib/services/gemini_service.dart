import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<String> extractTextFromMedia(Uint8List bytes, String mimeType) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    
    if (apiKey.isEmpty || apiKey == "MASUKKAN_API_KEY_BARU_DISINI") {
      throw Exception(
        "API Key belum disetel! Silakan masukkan API Key Anda di dalam file .env",
      );
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // Prompt instruksi
    const promptText =
        "Kamu adalah asisten pintar untuk aplikasi pembuat kuis. "
        "Tolong baca teks yang ada di gambar/dokumen ini. "
        "Jika ini adalah rekaman suara (audio), tolong transkripsikan (ubah suara menjadi teks) materinya. "
        "Hanya kembalikan teks materi aslinya saja tanpa tambahan basa-basi, tanpa markdown tambahan. "
        "Jika terdapat gambar yang tidak ada teksnya, deskripsikan isi gambarnya secara singkat.";

    final promptPart = TextPart(promptText);
    final mediaPart = DataPart(mimeType, bytes);

    try {
      final response = await model.generateContent([
        Content.multi([promptPart, mediaPart]),
      ]);

      return response.text?.trim() ?? "";
    } catch (e) {
      throw Exception("Gagal mengekstrak teks menggunakan Gemini: $e");
    }
  }
}
