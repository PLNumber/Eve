class UserModel {
  final String uid;
  final String name;        // 닉네임
  final String bio;         // 자기소개
  final int level;          // 레벨 (기본 1)
  final double accuracy;    // 정답률
  final int studyMinutes;   // 학습시간 (분)
  late final int attendance;     // 누적 출석일

  UserModel({
    required this.uid,
    required this.name,
    required this.bio,
    required this.level,
    required this.accuracy,
    required this.studyMinutes,
    required this.attendance,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? 'Player',
      bio: map['bio'] ?? '',
      level: map['level'] ?? 1,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      studyMinutes: map['studyMinutes'] ?? 0,
      attendance: map['attendance'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'level': level,
      'accuracy': accuracy,
      'studyMinutes': studyMinutes,
      'attendance': attendance,
    };
  }
}
