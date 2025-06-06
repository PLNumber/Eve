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
  String get login => 'Login';

  @override
  String get google_login => 'Google Login';

  @override
  String get settings => 'Settings';

  @override
  String get sound => 'Sound';

  @override
  String get sound_settings => 'Sound Settings';

  @override
  String get sound_on => 'Enable Sound';

  @override
  String get volume_level => 'Volume';

  @override
  String get select_music => 'Choose Music';

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
  String get language_selection => 'Select Language';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get nickname_change => 'Change Nickname';

  @override
  String get nickname_invalid => 'Nickname must be 2-10 characters long and can include Korean, English letters, and numbers.';

  @override
  String get nickname_taken => 'This nickname is already taken.';

  @override
  String get nickname_available => 'This nickname is available!';

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
  String get logout => 'Logout';

  @override
  String get confirm_logout => 'Do you really want to logout?';

  @override
  String get saved_message => 'Saved successfully!';

  @override
  String get close => 'Close';

  @override
  String get exit => 'Exit';

  @override
  String get confirm_exit_quiz => 'Are you sure you want to quit the quiz?';

  @override
  String get confirm_exit => 'Are you sure want to exit?';

  @override
  String get noNickname => 'No nickname';

  @override
  String get noEmail => 'No email';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String expProgress(int exp, int maxExp) {
    return 'Experience ($exp / $maxExp)';
  }

  @override
  String get resetDialogTitle => 'Really reset?';

  @override
  String get resetDialogContent => 'Deleted data cannot be recovered.';

  @override
  String get cancel => 'Cancel';

  @override
  String get historyCleared => 'History has been reset.';

  @override
  String get levelUpMessage => 'You\'ve leveled up! Congrats!';

  @override
  String get quizPageTitle => 'Take Quiz';

  @override
  String get quizErrorFetch => 'Failed to generate question: cannot reach server.';

  @override
  String get quizErrorNext => 'Unable to load the next question.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get confirm => 'OK';

  @override
  String get hint => 'Hint';

  @override
  String get submit => 'Submit';

  @override
  String difficultyBadge(int difficulty) {
    return 'Difficulty $difficulty';
  }

  @override
  String get reviewBadge => 'Review Question';

  @override
  String get answerHintDefault => 'Enter answer';

  @override
  String get setNicknameTitle => 'Set Nickname';

  @override
  String get promptEnterNickname => 'Please enter your nickname';

  @override
  String get exampleNickname => 'e.g., VocabularyKing123';

  @override
  String get invalidNicknameFormat => 'Nickname must be 2–10 chars, Korean/letters/numbers only.';

  @override
  String get nicknameDuplicateExists => 'This nickname is already in use.';

  @override
  String get nicknameAvailable => 'Nickname is available!';

  @override
  String get nicknameCheckError => 'Please check your nickname.';

  @override
  String get nicknameSaved => 'Nickname saved!';

  @override
  String get saveAndStart => 'Save & Start';

  @override
  String get next_question => 'skip';

  @override
  String get startWithGoogle => 'Start with Google';

  @override
  String welcomeUser(Object nickname) {
    return 'Welcome, $nickname!';
  }

  @override
  String get dailyLearning => 'Daily Learning';

  @override
  String get dailyGoal => 'Daily Goal : ';

  @override
  String goalCountUnit(int count) {
    return '$count words';
  }

  @override
  String todayLearnedWords(int count) {
    return 'Words Solved Today: $count';
  }

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get myStats => 'My Stats';

  @override
  String get totalSolved => 'Total Solved';

  @override
  String get correctSolved => 'Correct Answers';

  @override
  String get learningTime => 'Play Time';

  @override
  String days(int count) {
    return '${count}d';
  }

  @override
  String hours(int count) {
    return '${count}h';
  }

  @override
  String minutes(int count) {
    return '${count}m';
  }

  @override
  String levelInfo(Object level, Object exp, Object maxExp) {
    return 'Level $level ($exp / $maxExp)';
  }

  @override
  String get questionGrade => 'Question Grade';

  @override
  String get gradeMappingText => 'Level 1 ~ 9   : Grade 1\nLevel 10 ~ 24 : Grade 2\nLevel 25 ~ 49 : Grade 3\nLevel 50 ~ 74 : Grade 4\nLevel 75 ~ 100: Grade 5';

  @override
  String get wrongNote => 'Wrong Note';

  @override
  String get dictionary => 'Dictionary';

  @override
  String get weeklyAttendance => 'Weekly Attendance';

  @override
  String get testSet3DaysAgo => '⚙️ Test: Set date to 3 days ago';

  @override
  String consecutiveAttendance(int days) {
    return '✅ Consecutive attendance: $days days';
  }

  @override
  String monthlyAttendanceRate(String month, String rate) {
    return '📅 Attendance rate in month $month: $rate%';
  }

  @override
  String get noWrongAnswers => 'No saved wrong answers.';

  @override
  String get noWordInfo => 'No word information available.';

  @override
  String get partOfSpeechNone => 'No part of speech';

  @override
  String get dictionaryTitle => 'Korean Dictionary';

  @override
  String get searchHint => 'Enter search term';

  @override
  String get searchButton => 'Search';

  @override
  String get noResults => 'No search results.';

  @override
  String get apiError => 'API Error';

  @override
  String get networkError => 'Network Error';

  @override
  String get exactMatchTitle => '🔍 Exact Match';

  @override
  String get noExactMatch => 'No exact matches found.';

  @override
  String get partialMatchTitle => '📃 Related Words';

  @override
  String get noPartialMatch => 'No related words found.';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get rank => 'Rank';

  @override
  String get userId => 'User ID';

  @override
  String get correctSolved2 => 'Correct Solved';

  @override
  String get totalSolved2 => 'Total Solved';

  @override
  String get accuracyRate => 'Accuracy Rate';
}
