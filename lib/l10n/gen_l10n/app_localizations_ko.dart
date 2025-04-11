// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get title => '환영합니다';

  @override
  String get settings => '설정';

  @override
  String get change_language => '언어 변경';

  @override
  String get nickname_change => '닉네임 변경';

  @override
  String get logout => '로그아웃';

  @override
  String get confirm_logout => '정말로 로그아웃을 하시겠습니까?';

  @override
  String get language_selection => '언어 선택';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';
}
