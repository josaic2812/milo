enum MiloItemType { task, event, payment, checklist }
enum MiloPriority { urgent, normal, low }

class MiloItem {
  final String id;
  final MiloItemType type;
  final String title;
  final String detail;
  final String assignee;
  final String dueLabel;
  final DateTime? dueDate;
  final double? amount;
  final MiloPriority priority;
  bool completed;

  MiloItem({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.assignee,
    required this.dueLabel,
    required this.priority,
    this.dueDate,
    this.amount,
    this.completed = false,
  });

  MiloItem copyWith({String? assignee, bool? completed}) => MiloItem(
    id: id, type: type, title: title, detail: detail,
    assignee: assignee ?? this.assignee, dueLabel: dueLabel,
    dueDate: dueDate, amount: amount, priority: priority,
    completed: completed ?? this.completed,
  );
}
