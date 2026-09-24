import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/milo_shell.dart';
import 'family_repository.dart';
import 'family_invite_service.dart';
import 'supabase_config.dart';

class MiloAppFlow extends StatefulWidget {
  const MiloAppFlow({super.key});
  @override
  State<MiloAppFlow> createState() => _MiloAppFlowState();
}

class _MiloAppFlowState extends State<MiloAppFlow> {
  SupabaseClient get client => Supabase.instance.client;
  String? familyId;

  @override
  Widget build(BuildContext context) {
    // Do not access Supabase.instance before Supabase.initialize() has run.
    // This also makes the prototype start cleanly when no --dart-define values
    // have been supplied yet.
    if (!SupabaseConfig.isConfigured) {
      return const _SupabaseSetupScreen();
    }

    final session = client.auth.currentSession;
    if (session == null) {
      return MiloAuthScreen(onAuthenticated: () => setState(() {}));
    }

    if (familyId == null) {
      return MiloOnboardingScreen(
        onCreateFamily: (name) async {
          final family = await FamilyRepository(client).createFamily(name);
          await FamilyRepository(client).addMember(
            familyId: family.id,
            userId: session.user.id,
            name: session.user.email ?? 'Familienmitglied',
            role: 'owner',
          );
          if (mounted) setState(() => familyId = family.id);
        },
        onJoinFamily: (code) async {
          final id = await FamilyInviteService(client).joinFamily(
            code,
            session.user.id,
            session.user.email ?? 'Familienmitglied',
          );
          if (mounted) setState(() => familyId = id);
        },
      );
    }

    return MiloShell(familyId: familyId!);
  }
}

class _SupabaseSetupScreen extends StatelessWidget {
  const _SupabaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MILO',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Supabase ist noch nicht verbunden.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Der Prototyp startet jetzt ohne roten Fehler. Für Anmeldung, Familien und Synchronisation müssen anschließend SUPABASE_URL und SUPABASE_ANON_KEY über --dart-define gesetzt werden.',
                    style: TextStyle(fontSize: 15, height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SelectableText(
                      'flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
