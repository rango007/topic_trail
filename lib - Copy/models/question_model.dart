class QuestionModel {
  final String id;
  final String text;
  final List<String> options;
  final List<String?> nextQuestions;

  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.nextQuestions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'nextQuestions': nextQuestions,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'],
      text: map['text'],
      options: List<String>.from(map['options']),
      nextQuestions: List<String?>.from(map['nextQuestions']),
    );
  }
}
