# 🧹 Branch Cleanup Strategie - BillPal Persistenz

## 📋 Übersicht
Diese Datei dokumentiert alle TODO-Items und temporären Implementierungen, die am Ende des `persistenz` Branches aufgeräumt werden müssen.

**Ziel**: Vollständige Migration von Mock-Daten zu echter Persistenz mit sauberer Architektur.

---

## 🎯 Aktuelle Status (21. Oktober 2025)

### ✅ Implementiert (behalten):
- SQLite Persistenz-Layer (Desktop/Mobile)
- Repository Pattern mit Base-Repository
- Mock-Repository für Web-Kompatibilität
- Zentrale AppMode-Service mit Smart Detection

### 🔄 Temporär (für Cleanup markiert):
- Demo/Real Mode Switch
- Alle Demo-Daten in `invoice_service.dart`
- AppMode Enum und Service
- Mock-Daten Initialisierung

---

## 📝 TODO-Liste für Branch-Cleanup

### 🔴 PHASE 1: Kritische Aufräumarbeiten

#### 1. **AppMode Service entfernen**
```dart
// ENTFERNEN: /lib/core/app_mode/app_mode_service.dart
// GRUND: Nur für Übergangszeit nötig
```
- [ ] Alle `AppModeService()` Calls entfernen
- [ ] `AppMode` Enum löschen  
- [ ] Import-Referenzen cleanup

#### 2. **Demo-Daten aus invoice_service.dart entfernen**
```dart
// ENTFERNEN in: /lib/services/invoice_service.dart
- void initializeDemoData()
- void _createDemoFriends() 
- void _createDemoSharedBills()
- List<Person> _friends (Demo-Listen)
- List<SharedBill> _sharedBills (Demo-Listen)
```
- [ ] Kompletter `BillSharingService` Refactor
- [ ] Ersatz durch Repository-Pattern
- [ ] Demo-Event-Listen entfernen

#### 3. **Mock-Repositories auf Web beschränken**
```dart
// ANPASSEN: /lib/core/database/repositories/mock_repositories.dart
// NUR für Web behalten, Desktop/Mobile verwenden SQLite
```
- [ ] Platform-Detection für Mock-Usage
- [ ] Web-spezifische IndexedDB Integration (optional)

### 🟡 PHASE 2: Architektur-Cleanup

#### 4. **Service-Layer Refactoring**
```dart
// NEUER ANSATZ: Clean Architecture
/lib/features/
├── users/
│   ├── domain/
│   ├── data/
│   └── presentation/
├── bills/
│   ├── domain/
│   ├── data/
│   └── presentation/
```
- [ ] Feature-basierte Struktur implementieren
- [ ] Repository-Pattern durchgängig anwenden
- [ ] Service-Layer aufteilen in kleinere Einheiten

#### 5. **Model-Vereinheitlichung**
```dart
// PROBLEM: Doppelte Person-Models
// - /lib/models/invoice.dart (vollständig)
// - /lib/features/bills/presentation/pages/add_invoice_form.dart (vereinfacht)
```
- [ ] Vereinfachtes Person-Model entfernen
- [ ] Einheitliches Domain-Model verwenden
- [ ] Import-Referenzen updaten

### 🟢 PHASE 3: Code-Qualität & Performance

#### 6. **TODO-Kommentare Cleanup**
Alle Dateien mit `TODO: [CLEANUP]` Kommentaren durchgehen:
- [ ] `/lib/core/app_mode/app_mode_service.dart` → **KOMPLETTE DATEI LÖSCHEN**
- [ ] `/lib/services/invoice_service.dart` → **DEMO-LOGIK ENTFERNEN**
- [ ] `/lib/main.dart` → **AppMode Detection entfernen**

#### 7. **Import-Cleanup**
- [ ] Unused imports entfernen
- [ ] Import-Pfade optimieren
- [ ] Export-Dateien auf Korrektheit prüfen

#### 8. **Error-Handling Verbesserung**
- [ ] Comprehensive Error-Handling für Repository-Calls
- [ ] User-friendly Error-Messages
- [ ] Offline-Capability für Web

---

## 🔧 Automatisierte Cleanup-Schritte

### Shell-Skript für TODO-Suche:
```bash
# Alle CLEANUP-TODOs finden
grep -r "TODO: \[CLEANUP\]" lib/
grep -r "TODO.*[Cc]leanup" lib/
```

### Dart-Analyzer für unused code:
```bash
flutter analyze
dart fix --dry-run
```

---

## 📊 Cleanup-Timeline (Empfehlung)

### **Woche 1**: UI-Vervollständigung
- Welcome-Screen implementieren
- User-Setup Flow erstellen
- Friends-Management UI

### **Woche 2**: Repository Integration
- Real-Repository-Calls aktivieren
- Demo-Daten optional machen
- Testing mit echten Daten

### **Woche 3**: Cleanup Phase 1 + 2
- AppMode Service entfernen
- Service-Layer refactoring
- Model-Vereinheitlichung

### **Woche 4**: Cleanup Phase 3 + Testing
- Code-Qualität improvements
- Comprehensive Testing
- Performance-Optimierung

---

## ⚠️ Risiken & Fallstricke

### **Breaking Changes vermeiden:**
1. **Schritt-für-Schritt Migration**: Nie alles auf einmal ändern
2. **Feature-Flags nutzen**: Temporäre Switches für kritische Änderungen
3. **Backwards-Compatibility**: Bestehende Interfaces nicht brechen

### **Testing-Strategie:**
1. **Mock-zu-Real Tests**: Sicherstellen, dass Repository-Switch funktioniert
2. **Platform-Tests**: Web vs. Desktop/Mobile Verhalten
3. **Migration-Tests**: Demo-zu-Real Daten-Übergang

---

## 🎯 Definition of Done für Branch-Cleanup

### ✅ Erfolgskriterien:
- [ ] Keine `TODO: [CLEANUP]` Kommentare mehr im Code
- [ ] Keine Demo-Daten außer für onboarding/testing
- [ ] Einheitliches Repository-Pattern durchgängig
- [ ] Saubere Feature-basierte Architektur
- [ ] Web und Desktop funktionieren identisch (wo möglich)
- [ ] Alle Tests passing
- [ ] Performance-Benchmarks erfüllt
- [ ] Code-Coverage > 80%

---

*📅 Erstellt: 21. Oktober 2025*  
*🔄 Letztes Update: 21. Oktober 2025*  
*👤 Verantwortlich: Entwicklungsteam*