# MILO v0.2

## Neu in dieser Version

### 📷 Echte Scan-Pipeline
- Kamera
- Fotomediathek
- On-device OCR via Google ML Kit

### 🤖 KI-Schnittstelle
- `MiloAiService`
- sicherer Backend-Endpunkt vorgesehen
- JSON-Parsing für Aufgaben, Termine, Zahlungen, Zuständigkeit
- lokaler Demo-Fallback, damit die App sofort testbar bleibt

### 👨‍👩‍👧 Familienbasis
- Zuständigkeit
- gemeinsamer Status
- Supabase-Sync-Service vorbereitet
- SQL-Grundstruktur enthalten

## Start

```bash
flutter pub get
flutter run
```

## Wichtig

Für eine echte App-Store-Version müssen noch Backend, Authentifizierung,
Supabase-RLS, echte LLM-Anbindung, Push, Datenschutz und Accountlöschung
produktiv eingerichtet und getestet werden.
