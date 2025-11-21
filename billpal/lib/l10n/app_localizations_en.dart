// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BillPal';

  @override
  String get appSubtitle => 'Shared bills with friends';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get back => 'Back';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get menu => 'Menu';

  @override
  String get refresh => 'Refresh';

  @override
  String get drawerDashboard => 'Dashboard';

  @override
  String get drawerHistory => 'History';

  @override
  String get drawerMyFriends => 'My Friends';

  @override
  String get drawerAppearance => 'APPEARANCE';

  @override
  String get drawerLanguage => 'LANGUAGE';

  @override
  String get drawerLanguageInfo =>
      'Language and theme changes take effect immediately app-wide.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

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
    return 'You will receive $amount';
  }

  @override
  String youOwe(String amount) {
    return 'You owe $amount';
  }

  @override
  String get currentDebts => 'Current Debts';

  @override
  String get youOweColon => 'You owe:';

  @override
  String get owedToYouColon => 'Owed to you:';

  @override
  String get allBalanced => 'All settled! 🎉';

  @override
  String get noOpenDebts => 'You have no outstanding debts';

  @override
  String get recentBills => 'Recent Bills';

  @override
  String get showAll => 'Show all';

  @override
  String get noBillsYet => 'No bills yet';

  @override
  String get createFirstBill => 'Create your first shared bill';

  @override
  String get billHistory => 'Bill History';

  @override
  String get owedToMe => 'Owed to me';

  @override
  String get iOwe => 'I owe';

  @override
  String get paidByMe => 'Paid by me';

  @override
  String paidBy(String name) {
    return 'Paid by $name';
  }

  @override
  String itemCount(int count) {
    return '$count item';
  }

  @override
  String itemCountPlural(int count) {
    return '$count items';
  }

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusShared => 'Shared';

  @override
  String get statusSettled => 'Settled';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get addBill => 'Add Bill';

  @override
  String get shareBill => 'Share Bill';

  @override
  String get titleLabel => 'Title *';

  @override
  String get titleHint => 'e.g. Pizza night, Airbnb, Gas';

  @override
  String get titleRequired => 'Title required';

  @override
  String get dateTimeLabel => 'Date & Time *';

  @override
  String get positions => 'Items';

  @override
  String get addPosition => 'Add item';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'e.g. Margherita, Toll';

  @override
  String get required => 'Required';

  @override
  String get amountGross => 'Amount (Gross)';

  @override
  String get invalid => 'Invalid';

  @override
  String get mustBeGreaterZero => 'Must be > 0';

  @override
  String get person => 'Person';

  @override
  String get pleaseSelect => 'Please select';

  @override
  String get removePosition => 'Remove item';

  @override
  String get sum => 'Total';

  @override
  String get atLeastOnePosition => 'Please provide at least one valid item.';

  @override
  String billSavedSuccess(int id) {
    return 'Bill saved successfully! ID: $id';
  }

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get manualEntry => 'Enter manually';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get importFromGallery => 'Import from gallery/files';

  @override
  String get ocrNotSupported =>
      'OCR is not supported on web.\nPlease run on Android or iOS.';

  @override
  String get processingReceipt => 'Processing receipt...';

  @override
  String get noTextRecognized =>
      'No text recognized. Please try again.\nTips: Good lighting, flat receipt, sharp focus.';

  @override
  String get couldNotExtractData =>
      'Could not extract receipt data.\nOpen the form to enter manually.';

  @override
  String get details => 'Details';

  @override
  String get ocrRawText => 'OCR Raw Text';

  @override
  String errorScanning(String error) {
    return 'Error scanning: $error';
  }

  @override
  String get myFriends => 'My Friends';

  @override
  String get addFriend => 'Add friend';

  @override
  String friendAdded(String name) {
    return '$name has been added';
  }

  @override
  String friendRemoved(String name) {
    return '$name has been removed';
  }

  @override
  String errorAddingFriend(String error) {
    return 'Error adding: $error';
  }

  @override
  String errorRemovingFriend(String error) {
    return 'Error removing: $error';
  }

  @override
  String get removeFriend => 'Remove friend';

  @override
  String confirmRemoveFriend(String name) {
    return 'Do you really want to remove $name from your friends list?';
  }

  @override
  String get searchFriends => 'Search friends...';

  @override
  String get noFriendsYet => 'No friends added yet';

  @override
  String get addFriendsToShare => 'Add friends to share bills';

  @override
  String get addFirstFriend => 'Add first friend';

  @override
  String noFriendsFound(String query) {
    return 'No friends found for \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get nameLabel => 'Name *';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get phoneLabel => 'Phone (optional)';

  @override
  String friendCount(int count) {
    return '$count friend';
  }

  @override
  String friendCountPlural(int count) {
    return '$count friends';
  }

  @override
  String get noFriends => 'No friends';

  @override
  String get manageAll => 'Manage all';

  @override
  String get quickAddFriend => 'Quick add friend';

  @override
  String get noFriendsAdded => 'You haven\'t added any friends yet.';

  @override
  String get friendName => 'Friend\'s name';

  @override
  String get manageFriends => 'Manage friends';

  @override
  String friendAddedReopenForm(String name) {
    return '$name has been added! Please reopen the form.';
  }

  @override
  String get sharedExpenses => 'Shared Expenses';

  @override
  String get searchBillOrPerson => 'Search bill or person...';

  @override
  String get all => 'All';

  @override
  String get shared => 'Shared';

  @override
  String get settled => 'Settled';

  @override
  String get draft => 'Draft';

  @override
  String get noBillsFound => 'No bills found';

  @override
  String get noBillsAvailable => 'No bills available yet';

  @override
  String get tryOtherFilters => 'Try different search terms or filters';

  @override
  String get createFirstBillDashboard =>
      'Create your first bill via the dashboard';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get highestAmount => 'Highest amount';

  @override
  String get lowestAmount => 'Lowest amount';

  @override
  String get demoMode => 'Demo';

  @override
  String get realMode => 'Real';

  @override
  String get switchToReal => '🚀 Real mode activated! Using real database.';

  @override
  String errorLoadingFriends(String error) {
    return 'Error loading friends: $error';
  }

  @override
  String errorLoadingBills(String error) {
    return 'Error loading bills: $error';
  }

  @override
  String get categorySelect => 'Select category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String categoryAutoDetected(String category) {
    return 'Auto-detected: $category';
  }

  @override
  String categoryDetectedKeywords(String keywords) {
    return 'Detected keywords: $keywords';
  }

  @override
  String get categorySelectCorrect => 'Select the correct category:';

  @override
  String get categoryManage => 'Manage categories';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryOtherDesc => 'None of the above categories fit';

  @override
  String categoryChangedTo(String category) {
    return '✅ Category changed to \"$category\"';
  }

  @override
  String receiptFor(String title) {
    return 'Receipt: \"$title\"';
  }

  @override
  String get drawerCategories => 'Categories';
}
