class Evaluation {
  final String id;
  final String visiteId;
  final String userId;
  final String guideId;
  final double noteAccompagnement;
  final double noteConnaissance;
  final double noteAccueil;
  final double notePonctualite;
  final String commentaire;
  final DateTime date;

  Evaluation({
    required this.id,
    required this.visiteId,
    required this.userId,
    required this.guideId,
    required this.noteAccompagnement,
    required this.noteConnaissance,
    required this.noteAccueil,
    required this.notePonctualite,
    required this.commentaire,
    required this.date,
  });

  factory Evaluation.fromMap(Map<String, dynamic> data) {
    return Evaluation(
      id: data['id'] ?? '',
      visiteId: data['visiteId'] ?? '',
      userId: data['userId'] ?? '',
      guideId: data['guideId'] ?? '',
      noteAccompagnement: (data['noteAccompagnement'] as num?)?.toDouble() ?? 0.0,
      noteConnaissance: (data['noteConnaissance'] as num?)?.toDouble() ?? 0.0,
      noteAccueil: (data['noteAccueil'] as num?)?.toDouble() ?? 0.0,
      notePonctualite: (data['notePonctualite'] as num?)?.toDouble() ?? 0.0,
      commentaire: data['commentaire'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visiteId': visiteId,
      'userId': userId,
      'guideId': guideId,
      'noteAccompagnement': noteAccompagnement,
      'noteConnaissance': noteConnaissance,
      'noteAccueil': noteAccueil,
      'notePonctualite': notePonctualite,
      'commentaire': commentaire,
      'date': date.toIso8601String(),
    };
  }
}