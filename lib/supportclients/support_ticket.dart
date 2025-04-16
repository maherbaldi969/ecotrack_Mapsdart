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

  // Method to create a new support ticket
  static Future<void> creerTicket(
      String sujet, String description, String utilisateurId) async {
    // Logic to create a new ticket (e.g., API call)
    // This is a placeholder for the actual implementation
    print("Creating ticket with subject: $sujet");
  }

  // Method to modify an existing support ticket
  Future<void> modifierTicket(String newSujet, String newDescription) async {
    // Logic to modify the ticket (e.g., API call)
    // This is a placeholder for the actual implementation
    print("Modifying ticket: $id with new subject: $newSujet");
  }

  // Method to close a support ticket
  Future<void> fermerTicket() async {
    // Logic to close the ticket (e.g., API call)
    // This is a placeholder for the actual implementation
    print("Closing ticket: $id");
  }

  // Method to display the status of the ticket
  String afficherStatut() {
    return "Statut du ticket: $statut"; // Returns the status of the ticket
  }
}
