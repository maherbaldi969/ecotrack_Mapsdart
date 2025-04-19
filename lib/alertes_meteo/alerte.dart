class Alerte {
  String id;
  String type;
  String message;
  int utilisateurId;

  Alerte(this.id, this.type, this.message, this.utilisateurId);

  void envoyerAlerte() {
    // Logic to save the alert to a database or data structure
    // For example, you could add it to a list or send it to a backend service
    print('Alert sent: $message');
  }

  void afficherAlerte() {
    // Logic to retrieve and display the alert
    // This could involve fetching from a database or a list of alerts
    print('Alert: $message');
  }

  void supprimerAlerte() {
    // Logic to delete the alert from the data source
    // This could involve removing it from a list or sending a delete request to a backend service
    print('Alert deleted: $message');
  }
}
