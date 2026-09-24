import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyInviteService {
  final SupabaseClient client;
  const FamilyInviteService(this.client);

  Future<String> createInvite(String familyId) async {
    final code = _code();
    await client.from('family_invites').insert({
      'family_id': familyId,
      'code': code,
      'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    });
    return code;
  }

  Future<String> joinFamily(String code, String userId, String name) async {
    final invite = await client.from('family_invites').select('family_id,expires_at').eq('code', code.toUpperCase()).maybeSingle();
    if (invite == null) throw StateError('Einladung nicht gefunden.');
    final expiresAt = DateTime.tryParse(invite['expires_at'] as String? ?? '');
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) throw StateError('Diese Einladung ist abgelaufen.');
    final familyId = invite['family_id'] as String;
    await client.from('family_members').upsert({'family_id': familyId, 'user_id': userId, 'name': name, 'role': 'member'});
    return familyId;
  }

  String _code() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
