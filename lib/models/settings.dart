class AppSettings {
  final bool soundOn;
  final bool adsRemoved;
  final bool lowDataMode;

  AppSettings({
    this.soundOn = true,
    this.adsRemoved = false,
    this.lowDataMode = false,
  });

  AppSettings copyWith({
    bool? soundOn,
    bool? adsRemoved,
    bool? lowDataMode,
  }) {
    return AppSettings(
      soundOn: soundOn ?? this.soundOn,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      lowDataMode: lowDataMode ?? this.lowDataMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soundOn': soundOn,
      'adsRemoved': adsRemoved,
      'lowDataMode': lowDataMode,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      soundOn: map['soundOn'] as bool? ?? true,
      adsRemoved: map['adsRemoved'] as bool? ?? false,
      lowDataMode: map['lowDataMode'] as bool? ?? false,
    );
  }
}
