import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aufgaben')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text('Was ist zu tun?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        _group('Heute', [
          ('18 € für den Wandertag bezahlen', 'Josef', '18 €', true),
          ('Einverständniserklärung unterschreiben', 'Mama', 'Morgen', true),
        ]),
        _group('Demnächst', [
          ('Jause für den Wandertag vorbereiten', 'Familie', '21. Okt.', false),
          ('Sporttasche bereitstellen', 'Anna', '21. Okt.', false),
        ]),
      ],
    ),
  );

  Widget _group(String title, List<(String, String, String, bool)> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      ...rows.map((r) => Card(
        elevation: 0,
        child: ListTile(
          leading: Icon(r.$4 ? CupertinoIcons.circle : CupertinoIcons.checkmark_circle),
          title: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w650)),
          subtitle: Text(r.$2),
          trailing: Chip(label: Text(r.$3)),
        ),
      )),
      const SizedBox(height: 14),
    ],
  );
}
