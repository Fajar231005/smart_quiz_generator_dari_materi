import 'package:flutter/material.dart';
import 'input_page.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;

  const ResultPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    double percent = (score / total) * 100;

    String message;
    String emoji;

    if (percent == 100) {
      message = "Sempurna! MasyaAllah 🔥";
      emoji = "🏆";
    } else if (percent >= 80) {
      message = "Hebat, kamu sudah paham!";
      emoji = "🔥";
    } else if (percent >= 60) {
      message = "Lumayan, tingkatkan lagi ya!";
      emoji = "💪";
    } else if (percent > 0) {
      message = "Masih perlu belajar lagi 📚";
      emoji = "🙂";
    } else {
      message = "Yah belum benar 😢 ayo coba lagi!";
      emoji = "😢";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF220E04),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 EMOJI DINAMIS
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 60),
                ),

                const SizedBox(height: 10),

                // 🎯 PESAN DINAMIS
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // 💎 CARD SCORE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text("Skor Kamu"),
                      const SizedBox(height: 10),

                      Text(
                        "$score/$total",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${percent.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 15),

                      // 📊 PROGRESS BAR
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔁 BUTTON ULANGI (RESET TOTAL)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InputPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Ulangi 🔁",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}