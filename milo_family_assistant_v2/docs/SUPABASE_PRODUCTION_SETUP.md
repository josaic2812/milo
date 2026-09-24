# MILO – Supabase Produktions-Setup

## 1. Projekt anlegen
Erstelle ein Supabase-Projekt und notiere URL und anon key.

## 2. Datenbank
Führe `docs/SUPABASE.sql` im SQL Editor aus.

## 3. Realtime
Aktiviere Realtime für die Tabelle `items`, damit Änderungen in Familiengeräten sofort erscheinen.

## 4. Auth
MILO sollte für die Produktion Supabase Auth verwenden. Empfohlen: E-Mail + Magic Link oder Passwort. Familienmitgliedschaft darf nur über die `family_members`-Tabelle autorisiert werden.

## 5. Row Level Security
Die RLS-Regeln müssen so gestaltet werden, dass ein eingeloggter Benutzer ausschließlich Familien sehen und ändern kann, denen er über `family_members` zugeordnet ist. Keine offene `public`-Policy verwenden.

## 6. Flutter
Die Werte werden ausschließlich über Build-Variablen gesetzt:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Der anon key ist kein Ersatz für RLS. Die Sicherheit muss in Supabase Policies liegen.

## 7. Nächster Produktblock
- Login/Registrierung
- Familie erstellen
- Einladungscode/Einladungslink
- Mitgliedschaft prüfen
- Aufgaben realtime laden
- Push-Benachrichtigungen
- Account löschen / Datenschutz
