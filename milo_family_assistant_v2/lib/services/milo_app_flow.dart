import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/milo_shell.dart';
import 'family_repository.dart';
import 'family_invite_service.dart';

class MiloAppFlow extends StatefulWidget {
  const MiloAppFlow({super.key, this.client, this.initializationError});

  final SupabaseClient? client;
  final String? initializationError;

  @override
  State<MiloAppFlow> createState() => _MiloAppFlowState();
}

class _MiloAppFlowState extends State<MiloAppFlow> {
  String? familyId;

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    // The UI must remain usable even when Supabase is not configured yet.
    // Never touch Supabase.instance here: the singleton throws if initialize()
    // was not completed successfully.
    if (client == null) {
      return _SupabaseSetupScreen(error: widget.initializationError);
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
  const _SupabaseSetupScreen({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E6A4F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.family_restroom, color: green, size: 30),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MILO',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Der Familienhelfer',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      error == null
                          ? 'Die App läuft. Die Supabase-Verbindung ist für diesen Start noch nicht aktiviert.'
                          : 'Die App konnte die Supabase-Verbindung beim Start nicht initialisieren. Die Oberfläche bleibt trotzdem erreichbar.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Technische Details'),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              error!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .035),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Nächster Schritt: SUPABASE_URL und SUPABASE_ANON_KEY beim Start übergeben. Danach erscheinen Anmeldung, Familien und Synchronisation.',
                        style: TextStyle(fontSize: 14, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
