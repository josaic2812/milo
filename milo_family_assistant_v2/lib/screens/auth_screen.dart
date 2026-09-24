import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiloAuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  const MiloAuthScreen({super.key, this.onAuthenticated});
  @override State<MiloAuthScreen> createState() => _MiloAuthScreenState();
}

class _MiloAuthScreenState extends State<MiloAuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signUp = false, loading = false;
  String? error;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(() => error = 'Bitte E-Mail und ein Passwort mit mindestens 6 Zeichen eingeben.'); return;
    }
    setState(() { loading = true; error = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (signUp) {
        final r = await auth.signUp(email: email.text.trim(), password: password.text);
        if (r.session != null) widget.onAuthenticated?.call();
        else if (mounted) setState(() => error = 'Bitte bestätige zuerst deine E-Mail-Adresse.');
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
        widget.onAuthenticated?.call();
      }
    } on AuthException catch (e) { if (mounted) setState(() => error = e.message); }
    catch (_) { if (mounted) setState(() => error = 'Anmeldung derzeit nicht möglich.'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7F4),
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 62, height: 62, decoration: BoxDecoration(color: const Color(0xFF2E6A4F), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 28),
        Text(signUp ? 'Dein MILO-Konto' : 'Willkommen zurück', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(signUp ? 'Erstelle dein Konto und starte eure Familienzentrale.' : 'Melde dich an, um eure Familie zu öffnen.', style: const TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 26),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(CupertinoIcons.mail), labelText: 'E-Mail-Adresse')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(CupertinoIcons.lock), labelText: 'Passwort')),
          if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.redAccent))],
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: loading ? null : submit, child: Text(loading ? 'Bitte warten …' : signUp ? 'Konto erstellen' : 'Anmelden'))),
        ]))),
        const SizedBox(height: 10),
        Center(child: TextButton(onPressed: loading ? null : () => setState(() { signUp = !signUp; error = null; }), child: Text(signUp ? 'Ich habe bereits ein Konto' : 'Noch kein Konto? Jetzt registrieren'))),
      ]),
    )))),
  );
}
