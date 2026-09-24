import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kalender')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text('Termine', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('MILO sammelt wichtige Familientermine an einem Ort.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        _event('21. Okt.', 'Wandertag', '08:00 · Schule', CupertinoIcons.map),
        _event('24. Okt.', 'Elternabend', '19:00 · Schule', CupertinoIcons.person_2),
        _event('02. Nov.', 'Zahnarzt', '15:30 · Familie', CupertinoIcons.heart),
      ],
    ),
  );

  Widget _event(String date, String title, String detail, IconData icon) => Card(
    elevation: 0,
    child: ListTile(
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: const Color(0xFFE5EEE8), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: const Color(0xFF2E6A4F)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w750)),
      subtitle: Text(detail),
      trailing: Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
