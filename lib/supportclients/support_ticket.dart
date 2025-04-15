class SupportTicket {
  final String id;
  final String sujet;
  final String description;
  final String statut;
  final String utilisateurId;

  SupportTicket({
    required this.id,
    required this.sujet,
    required this.description,
    required this.statut,
    required this.utilisateurId,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      sujet: json['sujet'] ?? '',
      description: json['description'] ?? '',
      statut: json['statut'] ?? '',
      utilisateurId: json['utilisateur_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sujet': sujet,
      'description': description,
      'statut': statut,
      'utilisateur_id': utilisateurId,
    };
  }
}
