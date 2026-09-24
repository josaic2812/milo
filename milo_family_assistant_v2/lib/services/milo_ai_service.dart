import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/milo_item.dart';

class MiloAiService {
  /// In production set this to your secure backend endpoint.
  /// Never put an OpenAI/LLM secret directly into the iOS app.
  final String? backendUrl;

  MiloAiService({this.backendUrl});

  Future<List<MiloItem>> analyse(String text) async {
    if (backendUrl != null && backendUrl!.isNotEmpty) {
      final response = await http.post(
        Uri.parse(backendUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _decode(response.body);
      }
      throw Exception('KI-Server antwortete mit ${response.statusCode}');
    }
    return _demoAnalyse(text);
  }

  List<MiloItem> _decode(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final rows = (json['items'] as List<dynamic>? ?? []);
    return rows.map((raw) {
      final x = raw as Map<String, dynamic>;
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
        id: '${DateTime.now().microsecondsSinceEpoch}-${rows.indexOf(raw)}',
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

  List<MiloItem> _demoAnalyse(String text) {
    final lower = text.toLowerCase();
    final result = <MiloItem>[];
    String id(String suffix) => '${DateTime.now().microsecondsSinceEpoch}-$suffix';

    if (lower.contains('wandertag') || lower.contains('ausflug')) {
      result.add(MiloItem(
        id: id('event'), type: MiloItemType.event,
        title: 'Wandertag / Ausflug', detail: 'Termin aus dem Dokument erkannt',
        assignee: 'Familie', dueLabel: 'Termin prüfen',
        priority: MiloPriority.normal,
      ));
    }
    final money = RegExp(r'(\d+(?:[,.]\d{1,2})?)\s*(?:€|euro)',
            caseSensitive: false)
        .firstMatch(text);
    if (money != null) {
      result.add(MiloItem(
        id: id('payment'), type: MiloItemType.payment,
        title: '${money.group(1)} € bezahlen',
        detail: 'Geldbetrag aus dem Dokument erkannt',
        assignee: 'Josef', dueLabel: 'Frist prüfen',
        amount: double.tryParse(money.group(1)!.replaceAll(',', '.')),
        priority: MiloPriority.urgent,
      ));
    }
    if (lower.contains('unterschrift') || lower.contains('unterschrieben')) {
      result.add(MiloItem(
        id: id('signature'), type: MiloItemType.task,
        title: 'Unterschrift erledigen',
        detail: 'Eine Unterschrift wurde im Dokument erkannt',
        assignee: 'Mama', dueLabel: 'Frist prüfen',
        priority: MiloPriority.urgent,
      ));
    }
    if (lower.contains('mitbringen') || lower.contains('jause')) {
      result.add(MiloItem(
        id: id('bring'), type: MiloItemType.checklist,
        title: 'Benötigte Dinge vorbereiten',
        detail: 'Mitbringen / Jause wurde erkannt',
        assignee: 'Familie', dueLabel: 'Termin prüfen',
        priority: MiloPriority.low,
      ));
    }
    if (result.isEmpty) {
      result.add(MiloItem(
        id: id('generic'), type: MiloItemType.task,
        title: 'Information prüfen',
        detail: 'MILO hat Text erkannt, benötigt aber noch die echte KI-Analyse',
        assignee: 'Familie', dueLabel: 'Offen',
        priority: MiloPriority.normal,
      ));
    }
    return result;
  }
}
