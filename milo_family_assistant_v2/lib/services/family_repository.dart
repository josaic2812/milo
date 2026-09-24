import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family.dart';

class FamilyRepository {
  final SupabaseClient client;
  const FamilyRepository(this.client);

  Future<Family> createFamily(String name) async {
    final row = await client.from('families').insert({'name': name}).select().single();
    return Family(id: row['id'] as String, name: row['name'] as String);
  }

  Future<void> addMember({required String familyId, required String userId, required String name, String role = 'member'}) async {
    await client.from('family_members').insert({
      'family_id': familyId,
      'user_id': userId,
      'name': name,
      'role': role,
    });
  }

  Future<List<FamilyMember>> members(String familyId) async {
    final rows = await client.from('family_members').select().eq('family_id', familyId).order('name');
    return rows.map<FamilyMember>((row) => FamilyMember(
      id: row['user_id'] as String,
      name: row['name'] as String,
      role: row['role'] as String? ?? 'member',
    )).toList();
  }

  Stream<List<Map<String, dynamic>>> watchItems(String familyId) =>
      client.from('items').stream(primaryKey: ['id']).eq('family_id', familyId);

  Future<void> createItem({
    required String familyId,
    required String title,
    required String detail,
    required String type,
    required String assigneeName,
    String? dueLabel,
    DateTime? dueAt,
    double? amount,
  }) async {
    await client.from('items').insert({
      'family_id': familyId,
      'title': title,
      'detail': detail,
      'type': type,
      'assignee_name': assigneeName,
      'due_label': dueLabel,
      'due_at': dueAt?.toIso8601String(),
      'amount': amount,
      'status': 'open',
    });
  }

  Future<void> completeItem(String id) async {
    await client.from('items').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> assignItem(String id, String assigneeName) async {
    await client.from('items').update({'assignee_name': assigneeName}).eq('id', id);
  }
}
