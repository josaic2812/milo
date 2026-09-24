enum MiloItemType { task, event, payment, checklist }
enum MiloPriority { urgent, normal, low }

class MiloItem {
  final String id;
  final MiloItemType type;
  final String title;
  final String detail;
  String assignee;
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

  MiloItem copyWith({
    String? title,
    String? detail,
    String? assignee,
    String? dueLabel,
    DateTime? dueDate,
    double? amount,
    MiloPriority? priority,
    bool? completed,
  }) => MiloItem(
    id: id,
    type: type,
    title: title ?? this.title,
    detail: detail ?? this.detail,
    assignee: assignee ?? this.assignee,
    dueLabel: dueLabel ?? this.dueLabel,
    dueDate: dueDate ?? this.dueDate,
    amount: amount ?? this.amount,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
  );
}
