// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'BillPal';

  @override
  String get appSubtitle => 'Geteilte Rechnungen mit Freunden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get close => 'Schließen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get search => 'Suchen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get back => 'Zurück';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get loading => 'Lädt...';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get menu => 'Menü';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get drawerDashboard => 'Dashboard';

  @override
  String get drawerHistory => 'Historie';

  @override
  String get drawerMyFriends => 'Meine Freunde';

  @override
  String get drawerAppearance => 'ERSCHEINUNGSBILD';

  @override
  String get drawerLanguage => 'SPRACHE';

  @override
  String get drawerLanguageInfo => 'Sprachen und Theme wirken sofort app-weit.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get localeSystem => 'System';

  @override
  String get localeGerman => 'Deutsch';

  @override
  String get localeEnglish => 'English';

  @override
  String get dashboardTitle => 'BillPal';

  @override
  String youWillReceive(String amount) {
    return 'Du bekommst $amount';
  }

  @override
  String youOwe(String amount) {
    return 'Du schuldest $amount';
  }

  @override
  String get currentDebts => 'Aktuelle Schulden';

  @override
  String get youOweColon => 'Du schuldest:';

  @override
  String get owedToYouColon => 'Dir wird geschuldet:';

  @override
  String get allBalanced => 'Alles ausgeglichen! 🎉';

  @override
  String get noOpenDebts => 'Du hast keine offenen Schulden';

  @override
  String get recentBills => 'Letzte Rechnungen';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get noBillsYet => 'Noch keine Rechnungen';

  @override
  String get createFirstBill => 'Erstelle deine erste geteilte Rechnung';

  @override
  String get billHistory => 'Rechnungshistorie';

  @override
  String get owedToMe => 'Dir wird geschuldet';

  @override
  String get iOwe => 'Du schuldest';

  @override
  String get paidByMe => 'Von dir bezahlt';

  @override
  String paidBy(String name) {
    return 'Bezahlt von $name';
  }

  @override
  String itemCount(int count) {
    return '$count Position';
  }

  @override
  String itemCountPlural(int count) {
    return '$count Positionen';
  }

  @override
  String get statusDraft => 'Entwurf';

  @override
  String get statusShared => 'Geteilt';

  @override
  String get statusSettled => 'Beglichen';

  @override
  String get statusCancelled => 'Storniert';

  @override
  String get addBill => 'Rechnung hinzufügen';

  @override
  String get shareBill => 'Rechnung teilen';

  @override
  String get titleLabel => 'Titel *';

  @override
  String get titleHint => 'z. B. Pizzaabend, Airbnb, Tanken';

  @override
  String get titleRequired => 'Titel erforderlich';

  @override
  String get dateTimeLabel => 'Datum & Zeit *';

  @override
  String get positions => 'Positionen';

  @override
  String get addPosition => 'Position hinzufügen';

  @override
  String get description => 'Bezeichnung';

  @override
  String get descriptionHint => 'z. B. Margherita, Maut';

  @override
  String get required => 'Erforderlich';

  @override
  String get amountGross => 'Betrag (Brutto)';

  @override
  String get invalid => 'Ungültig';

  @override
  String get mustBeGreaterZero => 'Muss > 0 sein';

  @override
  String get person => 'Person';

  @override
  String get pleaseSelect => 'Bitte wählen';

  @override
  String get removePosition => 'Position entfernen';

  @override
  String get sum => 'Summe';

  @override
  String get whoPaidLabel => 'Wer hat bezahlt?';

  @override
  String get whoPaidHint => 'Person auswählen, die die Rechnung bezahlt hat';

  @override
  String get iPaid => 'Ich habe bezahlt';

  @override
  String get someoneElsePaid => 'Jemand anderes hat bezahlt';

  @override
  String get atLeastOnePosition =>
      'Bitte mindestens eine gültige Position angeben.';

  @override
  String billSavedSuccess(int id) {
    return 'Rechnung erfolgreich gespeichert! ID: $id';
  }

  @override
  String errorSaving(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get manualEntry => 'Manuell eingeben';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get importFromGallery => 'Aus Galerie/Dateien importieren';

  @override
  String get ocrNotSupported =>
      'OCR wird im Web nicht unterstützt.\nBitte auf Android oder iOS ausführen.';

  @override
  String get processingReceipt => 'Beleg wird verarbeitet...';

  @override
  String get noTextRecognized =>
      'Kein Text erkannt. Bitte versuche es erneut.\nTipps: Gute Beleuchtung, flacher Beleg, scharf fokussiert.';

  @override
  String get couldNotExtractData =>
      'Konnte keine Rechnungsdaten extrahieren.\nÖffne das Formular zum manuellen Eingeben.';

  @override
  String get details => 'Details';

  @override
  String get ocrRawText => 'OCR Rohtext';

  @override
  String errorScanning(String error) {
    return 'Fehler beim Scannen: $error';
  }

  @override
  String get myFriends => 'Meine Freunde';

  @override
  String get addFriend => 'Freund hinzufügen';

  @override
  String friendAdded(String name) {
    return '$name wurde hinzugefügt';
  }

  @override
  String friendRemoved(String name) {
    return '$name wurde entfernt';
  }

  @override
  String errorAddingFriend(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String errorRemovingFriend(String error) {
    return 'Fehler beim Entfernen: $error';
  }

  @override
  String get removeFriend => 'Freund entfernen';

  @override
  String confirmRemoveFriend(String name) {
    return 'Möchtest du $name wirklich aus deiner Freundesliste entfernen?';
  }

  @override
  String get searchFriends => 'Freunde suchen...';

  @override
  String get noFriendsYet => 'Noch keine Freunde hinzugefügt';

  @override
  String get addFriendsToShare => 'Füge Freunde hinzu, um Rechnungen zu teilen';

  @override
  String get addFirstFriend => 'Ersten Freund hinzufügen';

  @override
  String noFriendsFound(String query) {
    return 'Keine Freunde gefunden für \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Versuche einen anderen Suchbegriff';

  @override
  String get nameLabel => 'Name *';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get phoneLabel => 'Telefon (optional)';

  @override
  String friendCount(int count) {
    return '$count Freund';
  }

  @override
  String friendCountPlural(int count) {
    return '$count Freunde';
  }

  @override
  String get noFriends => 'Keine Freunde';

  @override
  String get manageAll => 'Alle verwalten';

  @override
  String get quickAddFriend => 'Schnell Freund hinzufügen';

  @override
  String get noFriendsAdded => 'Du hast noch keine Freunde hinzugefügt.';

  @override
  String get friendName => 'Name des Freundes';

  @override
  String get manageFriends => 'Freunde verwalten';

  @override
  String friendAddedReopenForm(String name) {
    return '$name wurde hinzugefügt! Bitte Form neu öffnen.';
  }

  @override
  String get sharedExpenses => 'Geteilte Ausgaben';

  @override
  String get searchBillOrPerson => 'Rechnung oder Person suchen...';

  @override
  String get all => 'Alle';

  @override
  String get shared => 'Geteilt';

  @override
  String get settled => 'Beglichen';

  @override
  String get draft => 'Entwurf';

  @override
  String get noBillsFound => 'Keine Rechnungen gefunden';

  @override
  String get noBillsAvailable => 'Noch keine Rechnungen vorhanden';

  @override
  String get tryOtherFilters => 'Versuche andere Suchbegriffe oder Filter';

  @override
  String get createFirstBillDashboard =>
      'Erstelle deine erste Rechnung über das Dashboard';

  @override
  String get newestFirst => 'Neueste zuerst';

  @override
  String get oldestFirst => 'Älteste zuerst';

  @override
  String get highestAmount => 'Höchster Betrag';

  @override
  String get lowestAmount => 'Niedrigster Betrag';

  @override
  String get demoMode => 'Demo';

  @override
  String get realMode => 'Real';

  @override
  String get switchToReal =>
      '🚀 Real-Mode aktiviert! Echte Datenbank wird verwendet.';

  @override
  String errorLoadingFriends(String error) {
    return 'Fehler beim Laden der Freunde: $error';
  }

  @override
  String errorLoadingBills(String error) {
    return 'Fehler beim Laden der Rechnungen: $error';
  }

  @override
  String get categorySelect => 'Kategorie auswählen';

  @override
  String get categoryEdit => 'Kategorie bearbeiten';

  @override
  String categoryAutoDetected(String category) {
    return 'Automatisch erkannt: $category';
  }

  @override
  String categoryDetectedKeywords(String keywords) {
    return 'Erkannte Keywords: $keywords';
  }

  @override
  String get categorySelectCorrect => 'Wähle die richtige Kategorie:';

  @override
  String get categoryManage => 'Kategorien verwalten';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get categoryOtherDesc => 'Keine der obigen Kategorien passt';

  @override
  String categoryChangedTo(String category) {
    return '✅ Kategorie zu \"$category\" geändert';
  }

  @override
  String receiptFor(String title) {
    return 'Rechnung: \"$title\"';
  }

  @override
  String get drawerCategories => 'Kategorien';

  @override
  String get categoryRestaurantFood => 'Restaurant & Essen';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Einkaufen';

  @override
  String get categoryHousing => 'Wohnen & Fixkosten';

  @override
  String get categoryOtherGeneral => 'Sonstiges';

  @override
  String billCountSingle(int count) {
    return '$count Rechnung';
  }

  @override
  String billCountPlural(int count) {
    return '$count Rechnungen';
  }
}
