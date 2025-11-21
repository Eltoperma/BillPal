# Projektdokumentation -- Flutter App zur Rechnungserfassung und Aufteilung

## Projektidee

Die Anwendung ermöglicht das Erfassen von Einkaufs- und
Restaurantbelegen per Kamera, Dateiimport oder manueller Eingabe. Ein
OCR-Prozess extrahiert Positionen, die anschließend einzelnen Personen
zugeordnet werden können. Auf Basis dieser Daten berechnet die App, wer
wem welchen Betrag schuldet oder erhält.

---

## Anforderungen & Ziele

-   Erfassen von Rechnungen über Kamera, Galerie oder Dateisystem\
-   OCR-Auswertung und Parsing der Positionen\
-   Manuelle Korrektur erkannter Daten\
-   Zuweisung einzelner Posten zu Personen\
-   Berechnung von Forderungen und Verbindlichkeiten\
-   Lokale Persistenz mit SQLite\
-   Übersicht über offene Posten und Historie\
-   Mehrsprachigkeit (aktuell DE, EN)
-   Dark-/Lightmode

---

## Architektur & Technisches Design

Die Architektur folgt einem modularen Aufbau mit getrennten Komponenten
für OCR, Datenhaltung, UI und Geschäftslogik. Daten werden lokal
gespeichert; sensible Informationen werden gesichert persistiert. Das UI
basiert auf Flutter und nutzt State-Management nach Bedarf.

Die Architektur lehnt sich an Feature Driven Design an. Funktionen wie Belegerfassung, OCR-Verarbeitung, Posten-Zuweisung oder Berechnung werden als eigene Feature-Bereiche umgesetzt. Jedes Feature bündelt seine Datenmodelle, Logik und UI-Teile, wodurch die App übersichtlich bleibt und sich einzelne Bereiche unabhängig weiterentwickeln lassen.

### Prozess - Rechnung anlegen
![Architekturdiagramm](Prozess-Rechnung-anlegen.png)

---

## Installationsanleitung

1.  Repository klonen\
2.  `flutter pub get` ausführen\
3.  Emulator oder Gerät verbinden\
4.  App starten mit `flutter run`

oder beigelegte APK herunterladen
<https://github.com/Eltoperma/BillPal/releases/tag/v1.0>
---

## Beispieldaten

Die App startet standartmäßig im Demo-Modus, dabei werden Beispieldaten geladen, um sich ein Bild von den Funktionalitäten zu machen. Dieser Modus kann durch das Klicken auf 'Real' umgesellt werden, sodass ausschließlich eigene Daten vorhanden sind.
Der Demo-Modus verwendet nur hard-codierte Daten, der Real-Modus speichert Daten local in der Datenbank 

---

## Logging

Jegliche Logs werden zentral über einen App-Logger abgewickelt, dieser ist nur über den Debug-Modus aktiv/verfügbar.

---

## BUGS 

- Die Berechnung der eigenen Schulden funktioniert manchmal nicht
- Rechnung begleichen und anschließend Rückgängig machen, wird in der Summe nicht berücksichtigt
- Das Parsing funktioniert bei einigen Rechnungen nicht vollständig
- Kreisdiagramm wird manchmal erst nach dem Refresh richtig berechnet

---

## Ausblick 

- Rechnung via QR-Code teilen ist noch nicht eingebaut (erneut krankheitsbedigt)
- Effizienteres Caching für weniger Datenbankaufrufe

---

## Autoren 

- Tjark Hüter (tjark.hueter@std.dhsh.de)
- Marten Schnack (marten.schnack@std.dhsh.de)
- Tom Schneider (tom-luca.schneider@std.dhsh.de)

---

## Lizenz

MIT License – frei verwendbar für Lern- und Demonstrationszwecke.
