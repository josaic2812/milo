import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/milo_item.dart';

class MiloItemCard extends StatelessWidget {
  final MiloItem item;
  final VoidCallback onToggle;
  final VoidCallback onAssign;

  const MiloItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) {
      MiloItemType.payment => Icons.euro_symbol,
      MiloItemType.event => CupertinoIcons.calendar,
      MiloItemType.checklist => CupertinoIcons.checkmark_square,
      MiloItemType.task => CupertinoIcons.checkmark_circle,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EAE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EFE9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2E6A4F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: item.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.detail, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(CupertinoIcons.person, size: 14),
                      label: Text(item.assignee),
                      onPressed: onAssign,
                    ),
                    Chip(
                      avatar: const Icon(CupertinoIcons.clock, size: 14),
                      label: Text(item.dueLabel),
                    ),
                    if (item.amount != null)
                      Chip(label: Text('${item.amount!.toStringAsFixed(0)} €')),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              item.completed
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
            ),
            color: const Color(0xFF2E6A4F),
          ),
        ],
      ),
    );
  }
}
