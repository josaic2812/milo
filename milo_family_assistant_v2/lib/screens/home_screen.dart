import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/milo_item.dart';
import '../services/milo_ai_service.dart';
import '../services/milo_store.dart';
import '../services/ocr_service.dart';
import '../widgets/milo_item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final store = MiloStore();
  final ai = MiloAiService(); // Production: inject your secure backend URL.
  final ocr = OcrService();
  final picker = ImagePicker();
  int tab = 0;
  bool busy = false;

  @override
  void dispose() {
    ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(
      index: tab,
      children: [_today(), _all(), _family()],
    )),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _captureMenu,
      icon: const Icon(CupertinoIcons.sparkles),
      label: const Text("Schick's MILO"),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(icon: Icon(CupertinoIcons.house), label: 'Heute'),
        NavigationDestination(icon: Icon(CupertinoIcons.list_bullet), label: 'Alles'),
        NavigationDestination(icon: Icon(CupertinoIcons.person_2), label: 'Familie'),
      ],
    ),
  );

  Widget _today() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      Row(children: [
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guten Morgen 👋', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 3),
            Text('Was steht an?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          ],
        )),
        _logo(),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2E6A4F), Color(0xFF4D896B)]),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Text('${store.open.length} offene Dinge',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 22),
      const Text('Heute & demnächst',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ...store.open.map(_card),
    ],
  );

  Widget _all() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      const Text('Familienübersicht',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('${store.items.length} Vorgänge · ${store.open.length} offen',
        style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      ...store.items.map(_card),
    ],
  );

  Widget _family() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      const Text('Familie',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Gemeinsam sehen, wer was erledigt.',
        style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      ...store.members.map((name) => ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3ECE6),
          child: Text(name.substring(0, 1)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${store.open.where((x) => x.assignee == name).length} offen'),
      )),
    ],
  );

  Widget _card(MiloItem item) => MiloItemCard(
    item: item,
    onToggle: () => setState(() => store.toggle(item)),
    onAssign: () => _assign(item),
  );

  Widget _logo() => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(color: const Color(0xFF2E6A4F), borderRadius: BorderRadius.circular(16)),
    alignment: Alignment.center,
    child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
  );

  void _captureMenu() => showModalBottomSheet(
    context: context, showDragHandle: true,
    builder: (_) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Align(alignment: Alignment.centerLeft,
          child: Text("Schick's einfach MILO",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 6),
        const Align(alignment: Alignment.centerLeft,
          child: Text('Foto, Text oder Dokument – MILO kümmert sich um den Rest.',
            style: TextStyle(color: Colors.black54))),
        const SizedBox(height: 15),
        _source(CupertinoIcons.camera, 'Foto aufnehmen', 'Schulzettel, Brief, Rechnung',
          () { Navigator.pop(context); _scan(ImageSource.camera); }),
        _source(CupertinoIcons.photo, 'Foto auswählen', 'Bild aus der Mediathek',
          () { Navigator.pop(context); _scan(ImageSource.gallery); }),
        _source(CupertinoIcons.doc_text, 'Text einfügen', 'Für Tests und E-Mails',
          () { Navigator.pop(context); _textInput(); }),
      ]),
    )),
  );

  Widget _source(IconData icon, String title, String sub, VoidCallback tap) => ListTile(
    leading: Container(
      width: 46, height: 46,
      decoration: BoxDecoration(color: const Color(0xFFE5EEE8), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: const Color(0xFF2E6A4F)),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(sub),
    trailing: const Icon(CupertinoIcons.chevron_right),
    onTap: tap,
  );

  Future<void> _scan(ImageSource source) async {
    try {
      final x = await picker.pickImage(source: source, imageQuality: 90);
      if (x == null) return;
      setState(() => busy = true);
      final text = await ocr.readImage(File(x.path));
      if (!mounted) return;
      setState(() => busy = false);
      if (text.isEmpty) {
        _message('MILO konnte auf dem Bild keinen Text erkennen.');
        return;
      }
      await _analyse(text);
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      _message('Scan konnte nicht verarbeitet werden: $e');
    }
  }

  Future<void> _textInput() async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Align(alignment: Alignment.centerLeft,
            child: Text('Text an MILO',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800))),
          const SizedBox(height: 12),
          TextField(
            controller: controller, maxLines: 7, autofocus: true,
            decoration: InputDecoration(
              hintText: 'E-Mail, Schulzettel oder Nachricht hier einfügen …',
              filled: true, fillColor: const Color(0xFFF0F3F0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(context);
                _analyse(value);
              },
              child: const Text('MILO analysieren lassen'),
            )),
        ]),
      ),
    );
  }

  Future<void> _analyse(String text) async {
    setState(() => busy = true);
    try {
      final result = await ai.analyse(text);
      if (!mounted) return;
      setState(() => busy = false);
      await showModalBottomSheet(
        context: context, isScrollControlled: true, showDragHandle: true,
        builder: (_) => SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(alignment: Alignment.centerLeft,
              child: Text('MILO hat das erkannt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
            const SizedBox(height: 5),
            const Align(alignment: Alignment.centerLeft,
              child: Text('Prüfe die Vorschläge, bevor sie für die Familie übernommen werden.',
                style: TextStyle(color: Colors.black54))),
            const SizedBox(height: 14),
            ...result.map((x) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(CupertinoIcons.checkmark_circle, color: Color(0xFF2E6A4F)),
              title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${x.assignee} · ${x.dueLabel}'),
            )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() => store.addAll(result));
                  Navigator.pop(context);
                  _message('MILO hat ${result.length} Vorgänge angelegt.');
                },
                child: const Text('Für alle übernehmen'),
              )),
          ]),
        )),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      _message('KI-Analyse fehlgeschlagen: $e');
    }
  }

  void _assign(MiloItem item) => showModalBottomSheet(
    context: context, showDragHandle: true,
    builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 8),
        child: Align(alignment: Alignment.centerLeft,
          child: Text('Wer ist zuständig?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
      ),
      ...store.members.map((name) => ListTile(
        title: Text(name),
        trailing: item.assignee == name ? const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF2E6A4F)) : null,
        onTap: () { setState(() => store.assign(item, name)); Navigator.pop(context); },
      )),
      const SizedBox(height: 15),
    ])),
  );

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}
