import 'package:flutter/material.dart';
import 'screens/milo_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiloApp());
}

class MiloApp extends StatelessWidget {
  const MiloApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E6A4F);
    return MaterialApp(
      title: 'MILO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
      ),
      home: const MiloShell(),
    );
  }
}
