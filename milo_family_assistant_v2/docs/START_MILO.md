# MILO lokal starten

## 1. Abhängigkeiten

Im Projektordner ausführen:

```bash
flutter pub get
```

## 2. Supabase verbinden

MILO verwendet absichtlich keine geheimen Supabase-Schlüssel im GitHub-Repository.

Project URL:

```text
https://jttytigfiftebuqjefcy.supabase.co
```

Den öffentlichen Publishable Key aus Supabase unter **Connect → Flutter** verwenden.

## 3. App starten

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://jttytigfiftebuqjefcy.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=DEIN_PUBLISHABLE_KEY
```

Unter Windows PowerShell kann der Befehl einzeilig verwendet werden:

```powershell
flutter run --dart-define=SUPABASE_URL=https://jttytigfiftebuqjefcy.supabase.co --dart-define=SUPABASE_ANON_KEY=DEIN_PUBLISHABLE_KEY
```

## Erster Test

1. Konto registrieren.
2. Familie erstellen.
3. Familienname eingeben.
4. Prüfen, ob der Datensatz in `families` erscheint.
5. Prüfen, ob das eigene Konto in `family_members` erscheint.
6. Danach testen wir Einladungscode, gemeinsame Aufgaben und Realtime.

**Niemals einen `service_role` oder Secret Key in die Flutter-App oder ins Repository eintragen.**
