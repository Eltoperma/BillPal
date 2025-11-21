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

## Funktionalitäten

### Dashboard

Im Dashboard lässt sich per Klick auf "Du Schuldest" oder "Dir wird geschuldet" direkt die Rechnungshistorie gefiltert anzeigen. Auch beim Klick auf eine Rechnungsvorschau unter "Letze Rechnungen" lässt sich die jeweilige Rechnung sofort aufklappen und anzeigen.

---

### Rechnung anlegen

Rechnungen lassen sich wie im Prozessdiagramm beschrieben anlegen. Dabei ist zu beachten, dass erst eine Person ausgewählt werden muss, welche die Rechnung bezahlt hat. Anschließend müssen die einzelnen Positionen zugewiesen werden. Die dafür möglichen Optionen werden dynamisch anhand der zahlenden Person berechnet (z.B.: Wer anders hat gezahlt, also bin ich der Schuldner).

### Historie 

Beim Klick auf eine Rechnung in der Historie lassen sich die einzelnen Positionen der Rechnung begleichen. Sind alle Positionen beglichen, wird eine Rechnung insgesamt als beglichen markiert und aus der Bilanz rausgerechnet.

---

### Kategorien

Die App ermöglicht es, verschiedene Kategorien zu verwalten. Diese lassen sich im Menü unter "Kategorien" bzw. "Categories" finden. Dort sind dann Standard Filterbegriffe für verschiedene Kategorien wie bspw. "Einkaufen" gelistet. Diese lassen sich durch benutzerdefinierte Tags erweitern. Die App filtert dann anschließend anhand der Schlüsselwörter beim Anlegen einer neuen Rechnung dessen Titel nach einem dieser Wörter und ordnet eine Rechnung automatisch einer Kategorie zu (zu sehen im Kreisdiagramm).

---

## Logging

Jegliche Logs werden zentral über einen App-Logger abgewickelt, dieser ist nur über den Debug-Modus aktiv/verfügbar.

---

## BUGS 

- Die Berechnung der eigenen Schulden funktioniert manchmal nicht
- Rechnung begleichen und anschließend Rückgängig machen, wird in der Summe nicht berücksichtigt
<<<<<<< Updated upstream
- Das Parsing funktioniert bei einigen Rechnungen nicht vollständig
- Kreisdiagramm wird manchmal erst nach dem Refresh richtig berechnet
- Es muss erst angegeben werden wer die Rechnung bezahlt hat, bevor die einzelnen Positionen zugeordnet werden können
=======
- Das Parsing funktioniert bei einigen Rechnungen nicht vollständig.
- Das Kreisdiagramm wird manchmal erst nach einem Refresh korrekt berechnet.
>>>>>>> Stashed changes

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
