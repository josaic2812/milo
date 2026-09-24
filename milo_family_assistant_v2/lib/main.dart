import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_config.dart';
import 'services/milo_app_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseClient? client;
  String? initializationError;

  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseConfig.initialize();
      client = SupabaseConfig.client;
    } catch (e) {
      initializationError = e.toString();
    }
  }

  runApp(MiloApp(
    client: client,
    initializationError: initializationError,
  ));
}

class MiloApp extends StatelessWidget {
  const MiloApp({super.key, this.client, this.initializationError});

  final SupabaseClient? client;
  final String? initializationError;

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
      home: MiloAppFlow(
        client: client,
        initializationError: initializationError,
      ),
    );
  }
}
