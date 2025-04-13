// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get waiting => '불러오는 중 . . .';

  @override
  String get title => '환영합니다';

  @override
  String get settings => '설정';

  @override
  String get sound => '소리 설정';

  @override
  String get reset_history => '기록 초기화';

  @override
  String get change_background => '배경 변경';

  @override
  String get default_background => '밝음(기본)';

  @override
  String get dark_background => '어두움';

  @override
  String get change_language => '언어 변경';

  @override
  String get nickname_change => '닉네임 변경';

  @override
  String get nickname_invalid => '닉네임은 2~10자, 한글/영문/숫자만 가능합니다.';

  @override
  String get nickname_taken => '이미 사용 중인 닉네임입니다.';

  @override
  String get nickname_available => '사용 가능한 닉네임입니다!';

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

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get check_duplicate => '중복 확인';

  @override
  String get change_nickname => '닉네임 변경';

  @override
  String get nickname_placeholder => '새 닉네임 입력';

  @override
  String get nickname_success => '닉네임이 변경되었습니다!';

  @override
  String get nickname_check_prompt => '닉네임 확인을 완료해주세요.';

  @override
  String get saved_message => '저장되었습니다!';

  @override
  String get exit => '종료';

  @override
  String get confirm_exit_quiz => '정말 퀴즈를 종료하시겠습니까?';

  @override
  String get confirm_exit => '정말 종료하시겠습니까?';

  @override
  String get sound_settings => '소리 설정';

  @override
  String get sound_on => '소리 켜기';

  @override
  String get volume_level => '음량';

  @override
  String get close => '닫기';

  @override
  String get select_music => '음악 선택';
}
