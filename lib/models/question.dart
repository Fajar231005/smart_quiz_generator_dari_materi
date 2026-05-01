// ================= MODEL =================
class Question {
  String question;
  List<String> options;
  int correctIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}