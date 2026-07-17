class Profile {
  final String deviceId;
  final String nickname;
  final int xp;
  final int streakCount;
  final int coins;
  final DateTime lastActiveDate;
  final String referralCode;

  Profile({
    required this.deviceId,
    required this.nickname,
    this.xp = 0,
    this.streakCount = 0,
    this.coins = 0,
    required this.lastActiveDate,
    required this.referralCode,
  });

  Profile copyWith({
    String? nickname,
    int? xp,
    int? streakCount,
    int? coins,
    DateTime? lastActiveDate,
    String? referralCode,
  }) {
    return Profile(
      deviceId: this.deviceId,
      nickname: nickname ?? this.nickname,
      xp: xp ?? this.xp,
      streakCount: streakCount ?? this.streakCount,
      coins: coins ?? this.coins,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'nickname': nickname,
      'xp': xp,
      'streakCount': streakCount,
      'coins': coins,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'referralCode': referralCode,
    };
  }

  factory Profile.fromMap(Map<dynamic, dynamic> map) {
    return Profile(
      deviceId: map['deviceId'] as String? ?? '',
      nickname: map['nickname'] as String? ?? 'Student',
      xp: map['xp'] as int? ?? 0,
      streakCount: map['streakCount'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      lastActiveDate: map['lastActiveDate'] != null 
          ? DateTime.parse(map['lastActiveDate'] as String)
          : DateTime.now(),
      referralCode: map['referralCode'] as String? ?? '',
    );
  }
}
