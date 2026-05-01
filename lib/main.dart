import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xFF220E04);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizify',
      theme: ThemeData(
        scaffoldBackgroundColor: primaryColor,
        primaryColor: primaryColor,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}