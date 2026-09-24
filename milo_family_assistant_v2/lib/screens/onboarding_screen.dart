import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MiloOnboardingScreen extends StatefulWidget {
  final Future<void> Function(String familyName)? onCreateFamily;
  final Future<void> Function(String inviteCode)? onJoinFamily;
  const MiloOnboardingScreen({super.key, this.onCreateFamily, this.onJoinFamily});
  @override State<MiloOnboardingScreen> createState() => _MiloOnboardingScreenState();
}

class _MiloOnboardingScreenState extends State<MiloOnboardingScreen> {
  final familyController = TextEditingController();
  final inviteController = TextEditingController();
  bool creating = false, joining = false;
  String? error;

  @override void dispose() { familyController.dispose(); inviteController.dispose(); super.dispose(); }

  Future<void> _create() async {
    final name = familyController.text.trim();
    if (name.isEmpty) { setState(() => error = 'Bitte einen Familiennamen eingeben.'); return; }
    setState(() { creating = true; error = null; });
    try { await widget.onCreateFamily?.call(name); }
    catch (e) { if (mounted) setState(() => error = 'Familie konnte nicht erstellt werden.'); }
    finally { if (mounted) setState(() => creating = false); }
  }

  Future<void> _join() async {
    final code = inviteController.text.trim();
    if (code.isEmpty) { setState(() => error = 'Bitte einen Einladungscode eingeben.'); return; }
    setState(() { joining = true; error = null; });
    try { await widget.onJoinFamily?.call(code); }
    catch (e) { if (mounted) setState(() => error = 'Einladung konnte nicht verwendet werden.'); }
    finally { if (mounted) setState(() => joining = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 44, 24, 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 62, height: 62, decoration: BoxDecoration(color: const Color(0xFF2E6A4F), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
      const SizedBox(height: 28),
      const Text('Willkommen bei MILO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Dein kleiner Familienhelfer.', style: TextStyle(fontSize: 17, color: Colors.black54)),
      const SizedBox(height: 34),
      _panel(icon: CupertinoIcons.person_3_fill, title: 'Familie erstellen', subtitle: 'Gemeinsame Aufgaben, Termine und Zahlungen an einem Ort.', child: Column(children: [
        TextField(controller: familyController, decoration: const InputDecoration(labelText: 'Name eurer Familie', hintText: 'z. B. Familie Aichberger', prefixIcon: Icon(CupertinoIcons.house))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: creating ? null : _create, child: Text(creating ? 'Wird erstellt …' : 'Familie erstellen'))),
      ])),
      const SizedBox(height: 18),
      _panel(icon: CupertinoIcons.link, title: 'Familie beitreten', subtitle: 'Du hast bereits eine Einladung von einem Familienmitglied?', child: Column(children: [
        TextField(controller: inviteController, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Einladungscode', hintText: 'z. B. ABC123', prefixIcon: Icon(CupertinoIcons.number))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: joining ? null : _join, child: Text(joining ? 'Wird verbunden …' : 'Familie beitreten'))),
      ])),
      if (error != null) ...[const SizedBox(height: 16), Text(error!, style: const TextStyle(color: Colors.redAccent))],
      const SizedBox(height: 24),
      const Center(child: Text('Deine Familiendaten bleiben geschützt.', style: TextStyle(color: Colors.black45, fontSize: 12))),
    ]))),
  );

  Widget _panel({required IconData icon, required String title, required String subtitle, required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE0E6E1))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFE5EEE8), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: const Color(0xFF2E6A4F))), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 16), child,
    ]),
  );
}
