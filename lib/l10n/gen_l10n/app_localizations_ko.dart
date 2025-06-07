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
  String get login => '로그인';

  @override
  String get google_login => '구글 로그인';

  @override
  String get settings => '설정';

  @override
  String get sound => '소리 설정';

  @override
  String get sound_settings => '소리 설정';

  @override
  String get sound_on => '소리 켜기';

  @override
  String get volume_level => '음량';

  @override
  String get select_music => '음악 선택';

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
  String get language_selection => '언어 선택';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';

  @override
  String get nickname_change => '닉네임 변경';

  @override
  String get nickname_invalid => '닉네임은 2~10자, 한글/영문/숫자만 가능합니다.';

  @override
  String get nickname_taken => '이미 사용 중인 닉네임입니다.';

  @override
  String get nickname_available => '사용 가능한 닉네임입니다!';

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
  String get logout => '로그아웃';

  @override
  String get confirm_logout => '정말로 로그아웃을 하시겠습니까?';

  @override
  String get saved_message => '저장되었습니다!';

  @override
  String get close => '닫기';

  @override
  String get exit => '종료';

  @override
  String get confirm_exit_quiz => '정말 퀴즈를 종료하시겠습니까?';

  @override
  String get confirm_exit => '정말 종료하시겠습니까?';

  @override
  String get noNickname => '닉네임 없음';

  @override
  String get noEmail => '이메일 없음';

  @override
  String levelLabel(int level) {
    return '레벨 $level';
  }

  @override
  String expProgress(int exp, int maxExp) {
    return '경험치 ($exp / $maxExp)';
  }

  @override
  String get resetDialogTitle => '정말 초기화할까요?';

  @override
  String get resetDialogContent => '삭제된 데이터는 복구할 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get historyCleared => '기록이 초기화되었습니다.';

  @override
  String get levelUpMessage => '레벨업! 축하합니다.';

  @override
  String get quizPageTitle => '퀴즈 풀기';

  @override
  String get quizErrorFetch => '문제 생성 실패: 서버에서 문제를 받아올 수 없습니다.';

  @override
  String get quizErrorNext => '다음 문제를 가져올 수 없습니다.';

  @override
  String get feedbackTitle => '피드백';

  @override
  String get confirm => '확인';

  @override
  String get hint => '힌트';

  @override
  String get submit => '제출';

  @override
  String difficultyBadge(int difficulty) {
    return '난이도 $difficulty';
  }

  @override
  String get reviewBadge => '복습 문제';

  @override
  String get answerHintDefault => '답 입력';

  @override
  String get setNicknameTitle => '닉네임 설정';

  @override
  String get promptEnterNickname => '닉네임을 입력해주세요';

  @override
  String get exampleNickname => '예: 어휘왕123';

  @override
  String get invalidNicknameFormat => '닉네임은 2~10자, 한글/영문/숫자만 가능합니다.';

  @override
  String get nicknameDuplicateExists => '이미 사용 중인 닉네임입니다.';

  @override
  String get nicknameAvailable => '사용 가능한 닉네임입니다!';

  @override
  String get nicknameCheckError => '닉네임을 확인해주세요.';

  @override
  String get nicknameSaved => '닉네임이 저장되었습니다!';

  @override
  String get saveAndStart => '저장하고 시작하기';

  @override
  String get next_question => '넘기기';

  @override
  String get startWithGoogle => '구글로 시작하기';

  @override
  String welcomeUser(Object nickname) {
    return '$nickname님 환영합니다!';
  }

  @override
  String get dailyLearning => '일일 학습';

  @override
  String get dailyGoal => '하루 목표 : ';

  @override
  String goalCountUnit(int count) {
    return '$count개';
  }

  @override
  String todayLearnedWords(int count) {
    return '오늘 푼 단어: $count개';
  }

  @override
  String get startQuiz => '퀴즈 시작하기';

  @override
  String get loadingQuiz => '다음 문제 생성 중...';

  @override
  String get myStats => '나의 통계';

  @override
  String get totalSolved => '총 푼 횟수';

  @override
  String get correctSolved => '맞춘 횟수';

  @override
  String get learningTime => '플레이 시간';

  @override
  String days(int count) {
    return '$count일';
  }

  @override
  String hours(int count) {
    return '$count시간';
  }

  @override
  String minutes(int count) {
    return '$count분';
  }

  @override
  String levelInfo(Object level, Object exp, Object maxExp) {
    return '레벨 $level ($exp / $maxExp)';
  }

  @override
  String get questionGrade => '출제 등급';

  @override
  String get gradeMappingText => '레벨 1 ~ 9   : 1등급\n레벨 10 ~ 24 : 2등급\n레벨 25 ~ 49 : 3등급\n레벨 50 ~ 74 : 4등급\n레벨 75 ~ 100: 5등급';

  @override
  String get wrongNote => '오답 노트';

  @override
  String get dictionary => '단어 사전';

  @override
  String get weeklyAttendance => '이번 주 출석';

  @override
  String get testSet3DaysAgo => '⚙️ 테스트: 3일 전으로 설정';

  @override
  String consecutiveAttendance(int days) {
    return '✅ 연속 출석: $days일';
  }

  @override
  String monthlyAttendanceRate(String month, String rate) {
    return '📅 $month월 출석률: $rate%';
  }

  @override
  String get noWrongAnswers => '저장된 오답이 없습니다.';

  @override
  String get noWordInfo => '단어 정보가 없습니다.';

  @override
  String get partOfSpeechNone => '품사 없음';

  @override
  String get dictionaryTitle => '우리말샘 사전';

  @override
  String get searchHint => '검색어를 입력하세요';

  @override
  String get searchButton => '검색';

  @override
  String get noResults => '검색 결과가 없습니다.';

  @override
  String get apiError => 'API 오류';

  @override
  String get networkError => '네트워크 오류';

  @override
  String get exactMatchTitle => '🔍 정확히 일치하는 단어';

  @override
  String get noExactMatch => '일치하는 결과가 없습니다.';

  @override
  String get partialMatchTitle => '📃 포함된 단어 결과';

  @override
  String get noPartialMatch => '포함된 단어가 없습니다.';

  @override
  String get leaderboard => '리더보드';

  @override
  String get rank => '순위';

  @override
  String get userId => '아이디';

  @override
  String get correctSolved2 => '맞은문제';

  @override
  String get totalSolved2 => '제출';

  @override
  String get accuracyRate => '정답비율';
}
