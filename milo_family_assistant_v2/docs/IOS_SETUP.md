# iOS Setup

Nach `flutter pub get`:

```bash
cd ios
pod install
cd ..
flutter run
```

In `ios/Runner/Info.plist` müssen für die Kamera/Fotos mindestens passende
Nutzungshinweise ergänzt werden, z.B.:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

Die genauen Texte müssen zur finalen Datenschutz-/App-Store-Kommunikation passen.

Google ML Kit Text Recognition benötigt die üblichen iOS Deployment-/Pod
Voraussetzungen des jeweils installierten Packages.

Für echte Push-Erinnerungen kommen später APNs/Firebase oder ein vergleichbarer
Push-Dienst hinzu.
