import '../models/question.dart';

// ================= GENERATOR =================
List<Question> generateQuestions(String text) {
  List<Question> questions = [];

  List<String> sentences = text.split(".");

  for (var s in sentences) {
    s = s.trim();
    if (s.isEmpty) continue;

    String questionText;
    String correctAnswer;

    if (s.contains("tahun")) {
      questionText = "Kapan ${s.replaceAll(RegExp(r'tahun \\d+'), '').trim()}?";
      correctAnswer = RegExp(r'\\d+').stringMatch(s) ?? "1945";
    } else if (s.contains("adalah")) {
      var parts = s.split("adalah");
      questionText = "Apa ${parts[0].trim()}?";
      correctAnswer = parts.length > 1 ? parts[1].trim() : "";
    } else {
      questionText = "Jelaskan: $s?";
      correctAnswer = s;
    }

    List<String> options = [
      correctAnswer,
      "Pilihan A",
      "Pilihan B",
      "Pilihan C",
    ];

    options.shuffle();

    int correctIndex = options.indexOf(correctAnswer);

    questions.add(
      Question(
        question: questionText,
        options: options,
        correctIndex: correctIndex,
      ),
    );
  }

  return questions;
}