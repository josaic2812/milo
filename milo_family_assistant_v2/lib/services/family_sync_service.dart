import 'package:supabase_flutter/supabase_flutter.dart';

class FamilySyncService {
  final SupabaseClient? client;
  FamilySyncService({this.client});

  bool get enabled => client != null;

  Future<void> saveItem({
    required String familyId,
    required String title,
    required String detail,
    required String assignee,
    required String type,
    String? dueLabel,
    double? amount,
  }) async {
    if (client == null) return;
    await client!.from('items').insert({
      'family_id': familyId,
      'title': title,
      'detail': detail,
      'assignee_name': assignee,
      'type': type,
      'due_label': dueLabel,
      'amount': amount,
      'status': 'open',
    });
  }

  Stream<List<Map<String, dynamic>>> watchFamily(String familyId) {
    if (client == null) return const Stream.empty();
    return client!
        .from('items')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId);
  }

  Future<void> complete(String id) async {
    if (client == null) return;
    await client!.from('items').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
