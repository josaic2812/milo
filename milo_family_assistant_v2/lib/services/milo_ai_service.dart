import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/milo_item.dart';
import 'milo_rule_engine.dart';

class MiloAiService {
  /// Production: use a secure backend. Never put an LLM secret in the app.
  final String? backendUrl;
  final MiloRuleEngine rules;

  MiloAiService({this.backendUrl, MiloRuleEngine? rules})
      : rules = rules ?? MiloRuleEngine();

  Future<List<MiloItem>> analyse(String text) async {
    final deterministic = rules.extract(text);

    if (backendUrl != null && backendUrl!.isNotEmpty) {
      final response = await http.post(
        Uri.parse(backendUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'local_items': deterministic.map(_encode).toList()}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final remote = _decode(response.body);
        return remote.isEmpty ? deterministic : _merge(remote, deterministic);
      }
      throw Exception('KI-Server antwortete mit ${response.statusCode}');
    }

    // Offline mode: the app remains useful without a network connection.
    return deterministic.isEmpty ? _fallback(text) : deterministic;
  }

  Map<String, dynamic> _encode(MiloItem item) => {
    'type': item.type.name,
    'title': item.title,
    'detail': item.detail,
    'assignee': item.assignee,
    'due_label': item.dueLabel,
    'amount': item.amount,
    'priority': item.priority.name,
  };

  List<MiloItem> _decode(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final rows = (json['items'] as List<dynamic>? ?? []);
    return rows.asMap().entries.map((entry) {
      final x = entry.value as Map<String, dynamic>;
      final type = switch (x['type']) {
        'event' => MiloItemType.event,
        'payment' => MiloItemType.payment,
        'checklist' => MiloItemType.checklist,
        _ => MiloItemType.task,
      };
      final priority = switch (x['priority']) {
        'urgent' => MiloPriority.urgent,
        'low' => MiloPriority.low,
        _ => MiloPriority.normal,
      };
      return MiloItem(
        id: '${DateTime.now().microsecondsSinceEpoch}-${entry.key}',
        type: type,
        title: '${x['title'] ?? 'Neue Aufgabe'}',
        detail: '${x['detail'] ?? ''}',
        assignee: '${x['assignee'] ?? 'Familie'}',
        dueLabel: '${x['due_label'] ?? 'Offen'}',
        amount: (x['amount'] as num?)?.toDouble(),
        priority: priority,
      );
    }).toList();
  }

  List<MiloItem> _merge(List<MiloItem> remote, List<MiloItem> local) {
    final result = [...remote];
    for (final localItem in local) {
      final exists = result.any((remoteItem) =>
          remoteItem.type == localItem.type &&
          remoteItem.title.toLowerCase() == localItem.title.toLowerCase());
      if (!exists) result.add(localItem);
    }
    return result;
  }

  List<MiloItem> _fallback(String text) => [
    MiloItem(
      id: '${DateTime.now().microsecondsSinceEpoch}-fallback',
      type: MiloItemType.task,
      title: 'Information prüfen',
      detail: text.replaceAll(RegExp(r'\s+'), ' ').trim(),
      assignee: 'Familie',
      dueLabel: 'Offen',
      priority: MiloPriority.normal,
    ),
  ];
}
