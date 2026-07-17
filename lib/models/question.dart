class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int difficulty; // 1 = Easy, 2 = Medium, 3 = Hard

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }

  factory Question.fromMap(Map<dynamic, dynamic> map) {
    return Question(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 1,
    );
  }
}
