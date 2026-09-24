import '../models/milo_item.dart';

/// Lightweight, deterministic extraction used before/alongside the real AI.
/// It keeps obvious facts useful even when the network is unavailable.
class MiloRuleEngine {
  static final _amount = RegExp(
    r'(\d+(?:[.,]\d{1,2})?)\s*(?:€|euro)',
    caseSensitive: false,
  );

  static final _date = RegExp(
    r'\b(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?\b',
  );

  List<MiloItem> extract(String text, {String defaultAssignee = 'Familie'}) {
    final lower = text.toLowerCase();
    final result = <MiloItem>[];
    final stamp = DateTime.now().microsecondsSinceEpoch;

    final amountMatch = _amount.firstMatch(text);
    if (amountMatch != null) {
      final value = double.tryParse(amountMatch.group(1)!.replaceAll(',', '.'));
      result.add(MiloItem(
        id: '$stamp-payment',
        type: MiloItemType.payment,
        title: value == null ? 'Zahlung prüfen' : '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} € bezahlen',
        detail: _shortContext(text),
        assignee: defaultAssignee,
        dueLabel: _dateLabel(text),
        amount: value,
        priority: MiloPriority.urgent,
        dueDate: _dateValue(text),
      ));
    }

    if (_containsAny(lower, ['wandertag', 'ausflug', 'termin', 'veranstaltung'])) {
      result.add(MiloItem(
        id: '$stamp-event',
        type: MiloItemType.event,
        title: _eventTitle(text),
        detail: _shortContext(text),
        assignee: 'Familie',
        dueLabel: _dateLabel(text),
        priority: MiloPriority.normal,
        dueDate: _dateValue(text),
      ));
    }

    if (_containsAny(lower, ['unterschrift', 'unterschreiben', 'abgeben', 'zurückgeben'])) {
      result.add(MiloItem(
        id: '$stamp-task',
        type: MiloItemType.task,
        title: lower.contains('unterschrift') || lower.contains('unterschreiben')
            ? 'Unterschrift erledigen'
            : 'Unterlagen abgeben',
        detail: _shortContext(text),
        assignee: defaultAssignee,
        dueLabel: _dateLabel(text),
        priority: MiloPriority.urgent,
        dueDate: _dateValue(text),
      ));
    }

    if (_containsAny(lower, ['mitbringen', 'jause', 'sportbekleidung', 'schuhe'])) {
      result.add(MiloItem(
        id: '$stamp-checklist',
        type: MiloItemType.checklist,
        title: 'Mitbringen / vorbereiten',
        detail: _shortContext(text),
        assignee: 'Familie',
        dueLabel: _dateLabel(text),
        priority: MiloPriority.low,
        dueDate: _dateValue(text),
      ));
    }

    return _deduplicate(result);
  }

  bool _containsAny(String text, List<String> values) =>
      values.any(text.contains);

  List<MiloItem> _deduplicate(List<MiloItem> input) {
    final seen = <String>{};
    return input.where((item) => seen.add('${item.type}-${item.title}')).toList();
  }

  String _eventTitle(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('wandertag')) return 'Wandertag';
    if (lower.contains('ausflug')) return 'Ausflug';
    return 'Termin';
  }

  String _shortContext(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized.length <= 100 ? normalized : '${normalized.substring(0, 97)}…';
  }

  String _dateLabel(String text) {
    final match = _date.firstMatch(text);
    return match == null ? 'Frist prüfen' : '${match.group(1)}.${match.group(2)}.';
  }

  DateTime? _dateValue(String text) {
    final match = _date.firstMatch(text);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    if (day == null || month == null) return null;
    final rawYear = match.group(3);
    final year = rawYear == null
        ? DateTime.now().year
        : (rawYear.length == 2 ? 2000 + int.parse(rawYear) : int.parse(rawYear));
    return DateTime(year, month, day);
  }
}
