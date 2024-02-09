class Word {
  final String word;
  final List<String> notes;
  int status;
  final DateTime addedOn = DateTime.now();

  Word(
      {required this.word,
      required this.notes,
      this.status = 0,
      required DateTime addedOn});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      notes: List<String>.from(json['notes']),
      status: json['status'],
      addedOn: DateTime.parse(json['addedOn']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'notes': notes,
      'status': status,
      'addedOn': addedOn.toIso8601String(),
    };
  }
}
