import '../models/milo_item.dart';

class MiloStore {
  final List<String> members = ['Josef', 'Mama', 'Anna', 'Emma', 'Lea'];

  final List<MiloItem> items = [
    MiloItem(
      id: '1', type: MiloItemType.payment,
      title: '18 € für den Wandertag bezahlen',
      detail: 'Schule · Wandertag', assignee: 'Josef',
      dueLabel: 'Heute', amount: 18, priority: MiloPriority.urgent,
    ),
    MiloItem(
      id: '2', type: MiloItemType.task,
      title: 'Einverständniserklärung unterschreiben',
      detail: 'Schule · Wandertag', assignee: 'Mama',
      dueLabel: 'Morgen', priority: MiloPriority.urgent,
    ),
    MiloItem(
      id: '3', type: MiloItemType.event,
      title: 'Wandertag', detail: 'Treffpunkt Schule · 08:00',
      assignee: 'Familie', dueLabel: '21. Okt.',
      priority: MiloPriority.normal,
    ),
  ];

  List<MiloItem> get open => items.where((x) => !x.completed).toList();

  void addAll(Iterable<MiloItem> values) => items.insertAll(0, values);

  void toggle(MiloItem item) => item.completed = !item.completed;

  void assign(MiloItem item, String person) => item.assignee = person;
}
