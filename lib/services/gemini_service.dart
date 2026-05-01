import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // TODO: Ganti dengan API Key Gemini Anda dari https://aistudio.google.com/
  static const apiKey = "AIzaSyCVJnQu7gdzlNt7PTdpr25Z1AqKg97GxVI";

  static Future<String> extractTextFromMedia(Uint8List bytes, String mimeType) async {
    if (apiKey.isEmpty || apiKey == "GANTI_DENGAN_API_KEY_GEMINI_ANDA") {
      throw Exception(
        "Silakan masukkan API Key Gemini di lib/services/gemini_service.dart terlebih dahulu.",
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
