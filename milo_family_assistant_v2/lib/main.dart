import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'services/milo_app_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
      home: const MiloAppFlow(),
    );
  }
}
