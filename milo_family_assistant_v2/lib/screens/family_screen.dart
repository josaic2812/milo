import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  static const members = [
    ('Josef', '3 offene Aufgaben', 'J'),
    ('Mama', '1 offene Aufgabe', 'M'),
    ('Anna', '2 offene Aufgaben', 'A'),
    ('Emma', '0 offene Aufgaben', 'E'),
    ('Lea', '1 offene Aufgabe', 'L'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Familie')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text('Euer Familienalltag', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Alle sehen, was ansteht und wer etwas übernimmt.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        ...members.map((m) => Card(
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFE5EEE8), child: Text(m.$3)),
            title: Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(m.$2),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
        )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.person_add),
          label: const Text('Familienmitglied einladen'),
        ),
      ],
    ),
  );
}
