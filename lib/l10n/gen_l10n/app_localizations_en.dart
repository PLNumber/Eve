// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get waiting => 'Loading . . . ';

  @override
  String get title => 'Welcome';

  @override
  String get settings => 'Settings';

  @override
  String get sound => 'Sound';

  @override
  String get reset_history => 'Reset History';

  @override
  String get change_background => 'Change Background';

  @override
  String get default_background => 'White(Default)';

  @override
  String get dark_background => 'Dark';

  @override
  String get change_language => 'Change Language';

  @override
  String get nickname_change => 'Change Nickname';

  @override
  String get logout => 'Logout';

  @override
  String get confirm_logout => 'Do you really want to logout?';

  @override
  String get language_selection => 'Select Language';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';
}
