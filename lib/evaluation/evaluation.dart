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

  void publierEvaluation() {
    // Logic to save the evaluation to a database or data source
    print('Evaluation published: $commentaire');
  }

  void modifierEvaluation(Map<String, dynamic> updatedData) {
    // Logic to modify the evaluation with updated data
    print('Evaluation modified: $id');
  }

  void supprimerEvaluation() {
    // Logic to delete the evaluation from the data source
    print('Evaluation deleted: $id');
  }

  void afficherEvaluation() {
    // Logic to display the evaluation details
    print('Evaluation: $commentaire');
  }

  String getMeta(String key) {
    // Logic to retrieve metadata associated with the evaluation
    return 'Meta for $key';
  }

  void setMeta(String key, String value) {
    // Logic to set metadata associated with the evaluation
    print('Meta set: $key = $value');
  }
}
