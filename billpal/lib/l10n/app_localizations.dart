import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Name der App
  ///
  /// In de, this message translates to:
  /// **'BillPal'**
  String get appTitle;

  /// Untertitel der App
  ///
  /// In de, this message translates to:
  /// **'Geteilte Rechnungen mit Freunden'**
  String get appSubtitle;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get error;

  /// No description provided for @success.
  ///
  /// In de, this message translates to:
  /// **'Erfolg'**
  String get success;

  /// No description provided for @menu.
  ///
  /// In de, this message translates to:
  /// **'Menü'**
  String get menu;

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get refresh;

  /// No description provided for @drawerDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get drawerDashboard;

  /// No description provided for @drawerHistory.
  ///
  /// In de, this message translates to:
  /// **'Historie'**
  String get drawerHistory;

  /// No description provided for @drawerMyFriends.
  ///
  /// In de, this message translates to:
  /// **'Meine Freunde'**
  String get drawerMyFriends;

  /// No description provided for @drawerAppearance.
  ///
  /// In de, this message translates to:
  /// **'ERSCHEINUNGSBILD'**
  String get drawerAppearance;

  /// No description provided for @drawerLanguage.
  ///
  /// In de, this message translates to:
  /// **'SPRACHE'**
  String get drawerLanguage;

  /// No description provided for @drawerLanguageInfo.
  ///
  /// In de, this message translates to:
  /// **'Sprachen und Theme wirken sofort app-weit.'**
  String get drawerLanguageInfo;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @localeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get localeSystem;

  /// No description provided for @localeGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get localeGerman;

  /// No description provided for @localeEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// No description provided for @dashboardTitle.
  ///
  /// In de, this message translates to:
  /// **'BillPal'**
  String get dashboardTitle;

  /// Zeigt an, dass der Benutzer Geld bekommt
  ///
  /// In de, this message translates to:
  /// **'Du bekommst {amount}'**
  String youWillReceive(String amount);

  /// Zeigt an, dass der Benutzer Geld schuldet
  ///
  /// In de, this message translates to:
  /// **'Du schuldest {amount}'**
  String youOwe(String amount);

  /// No description provided for @currentDebts.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Schulden'**
  String get currentDebts;

  /// No description provided for @youOweColon.
  ///
  /// In de, this message translates to:
  /// **'Du schuldest:'**
  String get youOweColon;

  /// No description provided for @owedToYouColon.
  ///
  /// In de, this message translates to:
  /// **'Dir wird geschuldet:'**
  String get owedToYouColon;

  /// No description provided for @allBalanced.
  ///
  /// In de, this message translates to:
  /// **'Alles ausgeglichen! 🎉'**
  String get allBalanced;

  /// No description provided for @noOpenDebts.
  ///
  /// In de, this message translates to:
  /// **'Du hast keine offenen Schulden'**
  String get noOpenDebts;

  /// No description provided for @recentBills.
  ///
  /// In de, this message translates to:
  /// **'Letzte Rechnungen'**
  String get recentBills;

  /// No description provided for @showAll.
  ///
  /// In de, this message translates to:
  /// **'Alle anzeigen'**
  String get showAll;

  /// No description provided for @noBillsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Rechnungen'**
  String get noBillsYet;

  /// No description provided for @createFirstBill.
  ///
  /// In de, this message translates to:
  /// **'Erstelle deine erste geteilte Rechnung'**
  String get createFirstBill;

  /// No description provided for @billHistory.
  ///
  /// In de, this message translates to:
  /// **'Rechnungshistorie'**
  String get billHistory;

  /// No description provided for @owedToMe.
  ///
  /// In de, this message translates to:
  /// **'Dir wird geschuldet'**
  String get owedToMe;

  /// No description provided for @iOwe.
  ///
  /// In de, this message translates to:
  /// **'Du schuldest'**
  String get iOwe;

  /// No description provided for @paidByMe.
  ///
  /// In de, this message translates to:
  /// **'Von dir bezahlt'**
  String get paidByMe;

  /// Zeigt an, wer die Rechnung bezahlt hat
  ///
  /// In de, this message translates to:
  /// **'Bezahlt von {name}'**
  String paidBy(String name);

  /// Anzahl der Positionen (Singular)
  ///
  /// In de, this message translates to:
  /// **'{count} Position'**
  String itemCount(int count);

  /// Anzahl der Positionen (Plural)
  ///
  /// In de, this message translates to:
  /// **'{count} Positionen'**
  String itemCountPlural(int count);

  /// No description provided for @statusDraft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get statusDraft;

  /// No description provided for @statusShared.
  ///
  /// In de, this message translates to:
  /// **'Geteilt'**
  String get statusShared;

  /// No description provided for @statusSettled.
  ///
  /// In de, this message translates to:
  /// **'Beglichen'**
  String get statusSettled;

  /// No description provided for @statusCancelled.
  ///
  /// In de, this message translates to:
  /// **'Storniert'**
  String get statusCancelled;

  /// No description provided for @addBill.
  ///
  /// In de, this message translates to:
  /// **'Rechnung hinzufügen'**
  String get addBill;

  /// No description provided for @shareBill.
  ///
  /// In de, this message translates to:
  /// **'Rechnung teilen'**
  String get shareBill;

  /// No description provided for @titleLabel.
  ///
  /// In de, this message translates to:
  /// **'Titel *'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Pizzaabend, Airbnb, Tanken'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In de, this message translates to:
  /// **'Titel erforderlich'**
  String get titleRequired;

  /// No description provided for @dateTimeLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum & Zeit *'**
  String get dateTimeLabel;

  /// No description provided for @positions.
  ///
  /// In de, this message translates to:
  /// **'Positionen'**
  String get positions;

  /// No description provided for @addPosition.
  ///
  /// In de, this message translates to:
  /// **'Position hinzufügen'**
  String get addPosition;

  /// No description provided for @description.
  ///
  /// In de, this message translates to:
  /// **'Bezeichnung'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Margherita, Maut'**
  String get descriptionHint;

  /// No description provided for @required.
  ///
  /// In de, this message translates to:
  /// **'Erforderlich'**
  String get required;

  /// No description provided for @amountGross.
  ///
  /// In de, this message translates to:
  /// **'Betrag (Brutto)'**
  String get amountGross;

  /// No description provided for @invalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültig'**
  String get invalid;

  /// No description provided for @mustBeGreaterZero.
  ///
  /// In de, this message translates to:
  /// **'Muss > 0 sein'**
  String get mustBeGreaterZero;

  /// No description provided for @person.
  ///
  /// In de, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @pleaseSelect.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen'**
  String get pleaseSelect;

  /// No description provided for @removePosition.
  ///
  /// In de, this message translates to:
  /// **'Position entfernen'**
  String get removePosition;

  /// No description provided for @sum.
  ///
  /// In de, this message translates to:
  /// **'Summe'**
  String get sum;

  /// No description provided for @whoPaidLabel.
  ///
  /// In de, this message translates to:
  /// **'Wer hat bezahlt?'**
  String get whoPaidLabel;

  /// No description provided for @whoPaidHint.
  ///
  /// In de, this message translates to:
  /// **'Person auswählen, die die Rechnung bezahlt hat'**
  String get whoPaidHint;

  /// No description provided for @iPaid.
  ///
  /// In de, this message translates to:
  /// **'Ich habe bezahlt'**
  String get iPaid;

  /// No description provided for @someoneElsePaid.
  ///
  /// In de, this message translates to:
  /// **'Jemand anderes hat bezahlt'**
  String get someoneElsePaid;

  /// No description provided for @atLeastOnePosition.
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens eine gültige Position angeben.'**
  String get atLeastOnePosition;

  /// Erfolgsmeldung nach Speichern
  ///
  /// In de, this message translates to:
  /// **'Rechnung erfolgreich gespeichert! ID: {id}'**
  String billSavedSuccess(int id);

  /// Fehlermeldung beim Speichern
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern: {error}'**
  String errorSaving(String error);

  /// No description provided for @manualEntry.
  ///
  /// In de, this message translates to:
  /// **'Manuell eingeben'**
  String get manualEntry;

  /// No description provided for @takePhoto.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get takePhoto;

  /// No description provided for @importFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie/Dateien importieren'**
  String get importFromGallery;

  /// No description provided for @ocrNotSupported.
  ///
  /// In de, this message translates to:
  /// **'OCR wird im Web nicht unterstützt.\nBitte auf Android oder iOS ausführen.'**
  String get ocrNotSupported;

  /// No description provided for @processingReceipt.
  ///
  /// In de, this message translates to:
  /// **'Beleg wird verarbeitet...'**
  String get processingReceipt;

  /// No description provided for @noTextRecognized.
  ///
  /// In de, this message translates to:
  /// **'Kein Text erkannt. Bitte versuche es erneut.\nTipps: Gute Beleuchtung, flacher Beleg, scharf fokussiert.'**
  String get noTextRecognized;

  /// No description provided for @couldNotExtractData.
  ///
  /// In de, this message translates to:
  /// **'Konnte keine Rechnungsdaten extrahieren.\nÖffne das Formular zum manuellen Eingeben.'**
  String get couldNotExtractData;

  /// No description provided for @details.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @ocrRawText.
  ///
  /// In de, this message translates to:
  /// **'OCR Rohtext'**
  String get ocrRawText;

  /// Fehlermeldung beim Scannen
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Scannen: {error}'**
  String errorScanning(String error);

  /// No description provided for @myFriends.
  ///
  /// In de, this message translates to:
  /// **'Meine Freunde'**
  String get myFriends;

  /// No description provided for @addFriend.
  ///
  /// In de, this message translates to:
  /// **'Freund hinzufügen'**
  String get addFriend;

  /// Erfolgsmeldung nach Hinzufügen eines Freundes
  ///
  /// In de, this message translates to:
  /// **'{name} wurde hinzugefügt'**
  String friendAdded(String name);

  /// Erfolgsmeldung nach Entfernen eines Freundes
  ///
  /// In de, this message translates to:
  /// **'{name} wurde entfernt'**
  String friendRemoved(String name);

  /// No description provided for @errorAddingFriend.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Hinzufügen: {error}'**
  String errorAddingFriend(String error);

  /// No description provided for @errorRemovingFriend.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Entfernen: {error}'**
  String errorRemovingFriend(String error);

  /// No description provided for @removeFriend.
  ///
  /// In de, this message translates to:
  /// **'Freund entfernen'**
  String get removeFriend;

  /// No description provided for @confirmRemoveFriend.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du {name} wirklich aus deiner Freundesliste entfernen?'**
  String confirmRemoveFriend(String name);

  /// No description provided for @searchFriends.
  ///
  /// In de, this message translates to:
  /// **'Freunde suchen...'**
  String get searchFriends;

  /// No description provided for @noFriendsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Freunde hinzugefügt'**
  String get noFriendsYet;

  /// No description provided for @addFriendsToShare.
  ///
  /// In de, this message translates to:
  /// **'Füge Freunde hinzu, um Rechnungen zu teilen'**
  String get addFriendsToShare;

  /// No description provided for @addFirstFriend.
  ///
  /// In de, this message translates to:
  /// **'Ersten Freund hinzufügen'**
  String get addFirstFriend;

  /// No description provided for @noFriendsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Freunde gefunden für \"{query}\"'**
  String noFriendsFound(String query);

  /// No description provided for @tryDifferentSearch.
  ///
  /// In de, this message translates to:
  /// **'Versuche einen anderen Suchbegriff'**
  String get tryDifferentSearch;

  /// No description provided for @nameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In de, this message translates to:
  /// **'Name ist erforderlich'**
  String get nameRequired;

  /// No description provided for @emailLabel.
  ///
  /// In de, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In de, this message translates to:
  /// **'Telefon (optional)'**
  String get phoneLabel;

  /// Anzahl der Freunde (Singular)
  ///
  /// In de, this message translates to:
  /// **'{count} Freund'**
  String friendCount(int count);

  /// Anzahl der Freunde (Plural)
  ///
  /// In de, this message translates to:
  /// **'{count} Freunde'**
  String friendCountPlural(int count);

  /// No description provided for @noFriends.
  ///
  /// In de, this message translates to:
  /// **'Keine Freunde'**
  String get noFriends;

  /// No description provided for @manageAll.
  ///
  /// In de, this message translates to:
  /// **'Alle verwalten'**
  String get manageAll;

  /// No description provided for @quickAddFriend.
  ///
  /// In de, this message translates to:
  /// **'Schnell Freund hinzufügen'**
  String get quickAddFriend;

  /// No description provided for @noFriendsAdded.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch keine Freunde hinzugefügt.'**
  String get noFriendsAdded;

  /// No description provided for @friendName.
  ///
  /// In de, this message translates to:
  /// **'Name des Freundes'**
  String get friendName;

  /// No description provided for @manageFriends.
  ///
  /// In de, this message translates to:
  /// **'Freunde verwalten'**
  String get manageFriends;

  /// No description provided for @friendAddedReopenForm.
  ///
  /// In de, this message translates to:
  /// **'{name} wurde hinzugefügt! Bitte Form neu öffnen.'**
  String friendAddedReopenForm(String name);

  /// No description provided for @sharedExpenses.
  ///
  /// In de, this message translates to:
  /// **'Geteilte Ausgaben'**
  String get sharedExpenses;

  /// No description provided for @searchBillOrPerson.
  ///
  /// In de, this message translates to:
  /// **'Rechnung oder Person suchen...'**
  String get searchBillOrPerson;

  /// No description provided for @all.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// No description provided for @shared.
  ///
  /// In de, this message translates to:
  /// **'Geteilt'**
  String get shared;

  /// No description provided for @settled.
  ///
  /// In de, this message translates to:
  /// **'Beglichen'**
  String get settled;

  /// No description provided for @draft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get draft;

  /// No description provided for @noBillsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Rechnungen gefunden'**
  String get noBillsFound;

  /// No description provided for @noBillsAvailable.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Rechnungen vorhanden'**
  String get noBillsAvailable;

  /// No description provided for @tryOtherFilters.
  ///
  /// In de, this message translates to:
  /// **'Versuche andere Suchbegriffe oder Filter'**
  String get tryOtherFilters;

  /// No description provided for @createFirstBillDashboard.
  ///
  /// In de, this message translates to:
  /// **'Erstelle deine erste Rechnung über das Dashboard'**
  String get createFirstBillDashboard;

  /// No description provided for @newestFirst.
  ///
  /// In de, this message translates to:
  /// **'Neueste zuerst'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In de, this message translates to:
  /// **'Älteste zuerst'**
  String get oldestFirst;

  /// No description provided for @highestAmount.
  ///
  /// In de, this message translates to:
  /// **'Höchster Betrag'**
  String get highestAmount;

  /// No description provided for @lowestAmount.
  ///
  /// In de, this message translates to:
  /// **'Niedrigster Betrag'**
  String get lowestAmount;

  /// No description provided for @demoMode.
  ///
  /// In de, this message translates to:
  /// **'Demo'**
  String get demoMode;

  /// No description provided for @realMode.
  ///
  /// In de, this message translates to:
  /// **'Real'**
  String get realMode;

  /// No description provided for @switchToReal.
  ///
  /// In de, this message translates to:
  /// **'🚀 Real-Mode aktiviert! Echte Datenbank wird verwendet.'**
  String get switchToReal;

  /// No description provided for @errorLoadingFriends.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Freunde: {error}'**
  String errorLoadingFriends(String error);

  /// No description provided for @errorLoadingBills.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Rechnungen: {error}'**
  String errorLoadingBills(String error);

  /// No description provided for @categorySelect.
  ///
  /// In de, this message translates to:
  /// **'Kategorie auswählen'**
  String get categorySelect;

  /// No description provided for @categoryEdit.
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get categoryEdit;

  /// No description provided for @categoryAutoDetected.
  ///
  /// In de, this message translates to:
  /// **'Automatisch erkannt: {category}'**
  String categoryAutoDetected(String category);

  /// No description provided for @categoryDetectedKeywords.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Keywords: {keywords}'**
  String categoryDetectedKeywords(String keywords);

  /// No description provided for @categorySelectCorrect.
  ///
  /// In de, this message translates to:
  /// **'Wähle die richtige Kategorie:'**
  String get categorySelectCorrect;

  /// No description provided for @categoryManage.
  ///
  /// In de, this message translates to:
  /// **'Kategorien verwalten'**
  String get categoryManage;

  /// No description provided for @categoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryOther;

  /// No description provided for @categoryOtherDesc.
  ///
  /// In de, this message translates to:
  /// **'Keine der obigen Kategorien passt'**
  String get categoryOtherDesc;

  /// No description provided for @categoryChangedTo.
  ///
  /// In de, this message translates to:
  /// **'✅ Kategorie zu \"{category}\" geändert'**
  String categoryChangedTo(String category);

  /// No description provided for @receiptFor.
  ///
  /// In de, this message translates to:
  /// **'Rechnung: \"{title}\"'**
  String receiptFor(String title);

  /// Drawer menu item for categories
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get drawerCategories;

  /// No description provided for @categoryRestaurantFood.
  ///
  /// In de, this message translates to:
  /// **'Restaurant & Essen'**
  String get categoryRestaurantFood;

  /// No description provided for @categoryEntertainment.
  ///
  /// In de, this message translates to:
  /// **'Unterhaltung'**
  String get categoryEntertainment;

  /// No description provided for @categoryTransport.
  ///
  /// In de, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In de, this message translates to:
  /// **'Einkaufen'**
  String get categoryShopping;

  /// No description provided for @categoryHousing.
  ///
  /// In de, this message translates to:
  /// **'Wohnen & Fixkosten'**
  String get categoryHousing;

  /// No description provided for @categoryOtherGeneral.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryOtherGeneral;

  /// Single bill count for pie chart
  ///
  /// In de, this message translates to:
  /// **'{count} Rechnung'**
  String billCountSingle(int count);

  /// Plural bill count for pie chart
  ///
  /// In de, this message translates to:
  /// **'{count} Rechnungen'**
  String billCountPlural(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
