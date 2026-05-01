import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_generator.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final String materi;

  const QuizPage({super.key, required this.materi});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> questions;
  int currentIndex = 0;
  int score = 0;

  int? selectedIndex;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    questions = generateQuestions(widget.materi);
  }

  void answerQuestion(int index) {
    if (isAnswered) return;

    setState(() {
      selectedIndex = index;
      isAnswered = true;

      if (index == questions[currentIndex].correctIndex) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
          isAnswered = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ResultPage(score: score, total: questions.length),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var q = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER + BACK
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 10),

              Text(
                "Soal ${currentIndex + 1}/${questions.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                backgroundColor: Colors.white,
                color: Colors.blue,
              ),

              const SizedBox(height: 30),

              // SOAL
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  q.question,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text("Pilih jawaban yang benar"),
              ),

              const SizedBox(height: 20),

              // OPTIONS
              ...List.generate(q.options.length, (index) {
                Color color = Colors.grey.shade300;

                if (isAnswered) {
                  if (index == q.correctIndex) {
                    color = Colors.green;
                  } else if (index == selectedIndex) {
                    color = Colors.red;
                  }
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isAnswered ? null : () => answerQuestion(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        q.options[index],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}