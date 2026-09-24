import 'package:flutter_test/flutter_test.dart';
import 'package:milo_family_assistant/services/milo_rule_engine.dart';
import 'package:milo_family_assistant/models/milo_item.dart';

void main() {
  test('extracts payment, event and signature from school note', () {
    const text = 'Wandertag am 21.10. Bitte 18 Euro bis 15.10. bezahlen. Unterschrift erforderlich.';
    final items = MiloRuleEngine().extract(text);

    expect(items.any((x) => x.type == MiloItemType.payment && x.amount == 18), isTrue);
    expect(items.any((x) => x.type == MiloItemType.event), isTrue);
    expect(items.any((x) => x.type == MiloItemType.task), isTrue);
    expect(items.any((x) => x.dueDate != null), isTrue);
  });

  test('does not duplicate the same extracted type and title', () {
    final items = MiloRuleEngine().extract('Wandertag Wandertag 20 Euro 20 Euro');
    final keys = items.map((x) => '${x.type}-${x.title}').toSet();
    expect(keys.length, items.length);
  });
}
