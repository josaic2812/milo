# Echte KI anschließen

Die App enthält bereits:
- Kamera / Galerie
- On-device OCR mit Google ML Kit
- Text-Analyse-Service
- HTTP-Schnittstelle für einen sicheren KI-Backend-Endpunkt

## Backend-Vertrag

POST `/analyse`

Request:
```json
{"text":"Wandertag am 21. Oktober. 18 Euro bis 15. Oktober bezahlen."}
```

Response:
```json
{
  "items": [
    {
      "type": "event",
      "title": "Wandertag",
      "detail": "Schule",
      "assignee": "Familie",
      "due_label": "21. Okt.",
      "priority": "normal"
    },
    {
      "type": "payment",
      "title": "18 € bezahlen",
      "detail": "Zahlung für Wandertag",
      "assignee": "Josef",
      "due_label": "15. Okt.",
      "amount": 18,
      "priority": "urgent"
    }
  ]
}
```

## Sicherheitsregel

Keinen LLM/API-Key in Flutter hinterlegen.

Produktiv:
Flutter -> eigener Backend-Endpunkt -> LLM/Vision -> validiertes JSON -> Flutter.

Der Backend-Endpunkt sollte Authentifizierung, Rate-Limits, Logging ohne unnötige
Dokumentinhalte und JSON-Schema-Validierung verwenden.
