import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/milo_shell.dart';
import 'family_repository.dart';
import 'family_invite_service.dart';

class MiloAppFlow extends StatefulWidget {
  const MiloAppFlow({super.key});
  @override State<MiloAppFlow> createState() => _MiloAppFlowState();
}

class _MiloAppFlowState extends State<MiloAppFlow> {
  SupabaseClient get client => Supabase.instance.client;
  String? familyId;

  @override Widget build(BuildContext context) {
    final session = client.auth.currentSession;
    if (session == null) return MiloAuthScreen(onAuthenticated: () => setState(() {}));
    if (familyId == null) return MiloOnboardingScreen(
      onCreateFamily: (name) async {
        final family = await FamilyRepository(client).createFamily(name);
        await FamilyRepository(client).addMember(familyId: family.id, userId: session.user.id, name: session.user.email ?? 'Familienmitglied', role: 'owner');
        if (mounted) setState(() => familyId = family.id);
      },
      onJoinFamily: (code) async {
        final id = await FamilyInviteService(client).joinFamily(code, session.user.id, session.user.email ?? 'Familienmitglied');
        if (mounted) setState(() => familyId = id);
      },
    );
    return MiloShell(familyId: familyId!);
  }
}
