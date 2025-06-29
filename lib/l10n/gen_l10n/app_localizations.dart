import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Loading . . . '**
  String get waiting;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get title;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @google_login.
  ///
  /// In en, this message translates to:
  /// **'Google Login'**
  String get google_login;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @sound_settings.
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get sound_settings;

  /// No description provided for @sound_on.
  ///
  /// In en, this message translates to:
  /// **'Enable Sound'**
  String get sound_on;

  /// No description provided for @volume_level.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume_level;

  /// No description provided for @select_music.
  ///
  /// In en, this message translates to:
  /// **'Choose Music'**
  String get select_music;

  /// No description provided for @reset_history.
  ///
  /// In en, this message translates to:
  /// **'Reset History'**
  String get reset_history;

  /// No description provided for @change_background.
  ///
  /// In en, this message translates to:
  /// **'Change Background'**
  String get change_background;

  /// No description provided for @default_background.
  ///
  /// In en, this message translates to:
  /// **'White(Default)'**
  String get default_background;

  /// No description provided for @dark_background.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark_background;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @language_selection.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language_selection;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @nickname_change.
  ///
  /// In en, this message translates to:
  /// **'Change Nickname'**
  String get nickname_change;

  /// No description provided for @nickname_invalid.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2-10 characters long and can include Korean, English letters, and numbers.'**
  String get nickname_invalid;

  /// No description provided for @nickname_taken.
  ///
  /// In en, this message translates to:
  /// **'This nickname is already taken.'**
  String get nickname_taken;

  /// No description provided for @nickname_available.
  ///
  /// In en, this message translates to:
  /// **'This nickname is available!'**
  String get nickname_available;

  /// No description provided for @check_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Check Duplicate'**
  String get check_duplicate;

  /// No description provided for @change_nickname.
  ///
  /// In en, this message translates to:
  /// **'Change Nickname'**
  String get change_nickname;

  /// No description provided for @nickname_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter new nickname'**
  String get nickname_placeholder;

  /// No description provided for @nickname_success.
  ///
  /// In en, this message translates to:
  /// **'Nickname changed successfully!'**
  String get nickname_success;

  /// No description provided for @nickname_check_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please complete the nickname check.'**
  String get nickname_check_prompt;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to logout?'**
  String get confirm_logout;

  /// No description provided for @saved_message.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully!'**
  String get saved_message;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @confirm_exit_quiz.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit the quiz?'**
  String get confirm_exit_quiz;

  /// No description provided for @confirm_exit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to exit?'**
  String get confirm_exit;

  /// Text when no nickname in profile
  ///
  /// In en, this message translates to:
  /// **'No nickname'**
  String get noNickname;

  /// Text when no email in profile
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Display current level in profile
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// Text above exp progress bar
  ///
  /// In en, this message translates to:
  /// **'Experience ({exp} / {maxExp})'**
  String expProgress(int exp, int maxExp);

  /// Dialog title for confirming reset
  ///
  /// In en, this message translates to:
  /// **'Really reset?'**
  String get resetDialogTitle;

  /// Dialog content for confirming reset
  ///
  /// In en, this message translates to:
  /// **'Deleted data cannot be recovered.'**
  String get resetDialogContent;

  /// Dialog cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Snackbar message after reset
  ///
  /// In en, this message translates to:
  /// **'History has been reset.'**
  String get historyCleared;

  /// Message shown when the user levels up
  ///
  /// In en, this message translates to:
  /// **'You\'ve leveled up! Congrats!'**
  String get levelUpMessage;

  /// AppBar title for quiz page
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get quizPageTitle;

  /// Shown when failing to fetch a quiz question
  ///
  /// In en, this message translates to:
  /// **'Failed to generate question: cannot reach server.'**
  String get quizErrorFetch;

  /// Shown when failing to fetch the next question
  ///
  /// In en, this message translates to:
  /// **'Unable to load the next question.'**
  String get quizErrorNext;

  /// Title for feedback dialog
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// Hint button label
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Submit answer button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text for difficulty badge
  ///
  /// In en, this message translates to:
  /// **'Difficulty {difficulty}'**
  String difficultyBadge(int difficulty);

  /// Label for review question badge
  ///
  /// In en, this message translates to:
  /// **'Review Question'**
  String get reviewBadge;

  /// Default hint text for answer field
  ///
  /// In en, this message translates to:
  /// **'Enter answer'**
  String get answerHintDefault;

  /// AppBar title for nickname setting page
  ///
  /// In en, this message translates to:
  /// **'Set Nickname'**
  String get setNicknameTitle;

  /// Prompt text for nickname input
  ///
  /// In en, this message translates to:
  /// **'Please enter your nickname'**
  String get promptEnterNickname;

  /// Example nickname hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., VocabularyKing123'**
  String get exampleNickname;

  /// Shown when nickname format is invalid
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2–10 chars, Korean/letters/numbers only.'**
  String get invalidNicknameFormat;

  /// Shown when nickname already taken
  ///
  /// In en, this message translates to:
  /// **'This nickname is already in use.'**
  String get nicknameDuplicateExists;

  /// Shown when nickname is available
  ///
  /// In en, this message translates to:
  /// **'Nickname is available!'**
  String get nicknameAvailable;

  /// Snackbar message on nickname check error
  ///
  /// In en, this message translates to:
  /// **'Please check your nickname.'**
  String get nicknameCheckError;

  /// Snackbar message when nickname saved
  ///
  /// In en, this message translates to:
  /// **'Nickname saved!'**
  String get nicknameSaved;

  /// Label for Save & Start button
  ///
  /// In en, this message translates to:
  /// **'Save & Start'**
  String get saveAndStart;

  /// No description provided for @next_question.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get next_question;

  /// Label for the Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Start with Google'**
  String get startWithGoogle;

  /// Greeting the logged-in user
  ///
  /// In en, this message translates to:
  /// **'Welcome, {nickname}!'**
  String welcomeUser(Object nickname);

  /// No description provided for @dailyLearning.
  ///
  /// In en, this message translates to:
  /// **'Daily Learning'**
  String get dailyLearning;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal : '**
  String get dailyGoal;

  /// Daily goal in word units
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String goalCountUnit(int count);

  /// Shows number of words solved today
  ///
  /// In en, this message translates to:
  /// **'Words Solved Today: {count}'**
  String todayLearnedWords(int count);

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @loadingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Generate Next Quiz...'**
  String get loadingQuiz;

  /// No description provided for @myStats.
  ///
  /// In en, this message translates to:
  /// **'My Stats'**
  String get myStats;

  /// No description provided for @totalSolved.
  ///
  /// In en, this message translates to:
  /// **'Total Solved'**
  String get totalSolved;

  /// No description provided for @correctSolved.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctSolved;

  /// No description provided for @learningTime.
  ///
  /// In en, this message translates to:
  /// **'Play Time'**
  String get learningTime;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String days(int count);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hours(int count);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutes(int count);

  /// No description provided for @levelInfo.
  ///
  /// In en, this message translates to:
  /// **'Level {level} ({exp} / {maxExp})'**
  String levelInfo(Object level, Object exp, Object maxExp);

  /// No description provided for @questionGrade.
  ///
  /// In en, this message translates to:
  /// **'Question Grade'**
  String get questionGrade;

  /// Description for level-based grading
  ///
  /// In en, this message translates to:
  /// **'Level 1 ~ 9   : Grade 1\nLevel 10 ~ 24 : Grade 2\nLevel 25 ~ 49 : Grade 3\nLevel 50 ~ 74 : Grade 4\nLevel 75 ~ 100: Grade 5'**
  String get gradeMappingText;

  /// No description provided for @wrongNote.
  ///
  /// In en, this message translates to:
  /// **'Wrong Note'**
  String get wrongNote;

  /// No description provided for @dictionary.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get dictionary;

  /// No description provided for @weeklyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Weekly Attendance'**
  String get weeklyAttendance;

  /// No description provided for @testSet3DaysAgo.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Test: Set date to 3 days ago'**
  String get testSet3DaysAgo;

  /// Shows number of consecutive attendance days
  ///
  /// In en, this message translates to:
  /// **'✅ Consecutive attendance: {days} days'**
  String consecutiveAttendance(int days);

  /// Monthly attendance rate with percentage
  ///
  /// In en, this message translates to:
  /// **'📅 Attendance rate in month {month}: {rate}%'**
  String monthlyAttendanceRate(String month, String rate);

  /// No description provided for @noWrongAnswers.
  ///
  /// In en, this message translates to:
  /// **'No saved wrong answers.'**
  String get noWrongAnswers;

  /// No description provided for @noWordInfo.
  ///
  /// In en, this message translates to:
  /// **'No word information available.'**
  String get noWordInfo;

  /// No description provided for @partOfSpeechNone.
  ///
  /// In en, this message translates to:
  /// **'No part of speech'**
  String get partOfSpeechNone;

  /// No description provided for @dictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Korean Dictionary'**
  String get dictionaryTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter search term'**
  String get searchHint;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No search results.'**
  String get noResults;

  /// No description provided for @apiError.
  ///
  /// In en, this message translates to:
  /// **'API Error'**
  String get apiError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @exactMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'🔍 Exact Match'**
  String get exactMatchTitle;

  /// No description provided for @noExactMatch.
  ///
  /// In en, this message translates to:
  /// **'No exact matches found.'**
  String get noExactMatch;

  /// No description provided for @partialMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'📃 Related Words'**
  String get partialMatchTitle;

  /// No description provided for @noPartialMatch.
  ///
  /// In en, this message translates to:
  /// **'No related words found.'**
  String get noPartialMatch;

  /// Title for the leaderboard section
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Column title for rank in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// Column title for user nickname/ID in leaderboard
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// Column title for number of correct answers in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Correct Solved'**
  String get correctSolved2;

  /// Column title for total number of submissions in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Total Solved'**
  String get totalSolved2;

  /// Column title for percentage accuracy in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Accuracy Rate'**
  String get accuracyRate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
