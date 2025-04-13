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
  String get nickname_invalid => 'Nickname must be 2-10 characters long and can include Korean, English letters, and numbers.';

  @override
  String get nickname_taken => 'This nickname is already taken.';

  @override
  String get nickname_available => 'This nickname is available!';

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

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get check_duplicate => 'Check Duplicate';

  @override
  String get change_nickname => 'Change Nickname';

  @override
  String get nickname_placeholder => 'Enter new nickname';

  @override
  String get nickname_success => 'Nickname changed successfully!';

  @override
  String get nickname_check_prompt => 'Please complete the nickname check.';

  @override
  String get saved_message => 'Saved successfully!';

  @override
  String get exit => 'Exit';

  @override
  String get confirm_exit_quiz => 'Are you sure you want to quit the quiz?';

  @override
  String get confirm_exit => 'Are you sure want to exit?';

  @override
  String get sound_settings => 'Sound Settings';

  @override
  String get sound_on => 'Enable Sound';

  @override
  String get volume_level => 'Volume';

  @override
  String get close => 'Close';

  @override
  String get select_music => 'Choose Music';
}
